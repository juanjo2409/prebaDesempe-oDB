# Documentación del Proceso de Normalización y Diseño de Base de Datos
## EcoMarket Riwi S.A.S.

---

## 1. Introducción y Estado Inicial

EcoMarket Riwi S.A.S. ha operado durante varios años mediante una única hoja de cálculo plana de Excel (`Dataset_EcoMarketRiwi_Jornada_Tarde.xlsx`) que recopilaba toda la operación comercial, logística e inventarios. 

En este estado inicial, la información se guardaba de manera desestructurada en una única tabla con las siguientes columnas:
* `ClientName` (Nombre del cliente)
* `City` (Ciudad de entrega)
* `Product` (Nombre del producto)
* `Category` (Categoría del producto)
* `DistributionCenter` (Centro de distribución)
* `OrderID` (Identificador del pedido)
* `OrderDate` (Fecha del pedido)
* `Quantity` (Cantidad ordenada)
* `UnitPrice` (Precio unitario)
* `Stock` (Existencias de producto)

---

## 2. Inconsistencias y Redundancias Detectadas

Al inspeccionar los 20 registros operativos del Excel, se identificaron los siguientes problemas graves de integridad y calidad de datos:

1. **Clientes Duplicados**:
   * Registros repetidos con variaciones de mayúsculas, espacios y caracteres especiales. Ejemplos: `SuperMax` vs `super max` vs `SuperMax `; `FreshMart` vs `Fresh Mart`.
2. **Nombres de Ciudades Inconsistentes**:
   * Nombres con tildes omitidas, mayúsculas sostenidas, errores ortográficos o abreviaciones. Ejemplos: `Bogotá` vs `Bogota`; `Cali` vs `CALI`; `Bucaramanga` vs `B/manga`; `Pereira` vs `Pereria`; `Manizales` vs `Manizalez`.
3. **Productos Repetidos con Nombres Diferentes**:
   * Descripciones del mismo artículo escritas de forma distinta. Ejemplos: `Apple Gala` vs `Gala Apple`; `Whole Milk` vs `Milk 1L`; `Eggs x12` vs `Dozen Eggs`; `Tomato` vs `Tomatoes`.
4. **Categorías Inconsistentes**:
   * Mezcla de singular y plural para la misma agrupación. Ejemplos: `Fruits` vs `Fruit`; `Vegetables` vs `Vegetable`; `Grains` vs `Grain`.
5. **Centros de Distribución Duplicados**:
   * Nombres de bodegas invertidos o escritos de forma errónea. Ejemplos: `Center North` vs `North Center`; `Coast DC` vs `Coastal DC`; `Coffee DC` vs `Coffee Center`.
6. **Redundancia Logística y Transaccional**:
   * Cada fila del pedido repetía toda la información del cliente, ciudad y centro de distribución. Si un cliente cambia de nombre o una ciudad de centro de distribución, habría que actualizar miles de filas (anomalía de actualización).

---

## 3. Proceso de Normalización (1FN, 2FN, 3FN)

Para solucionar estos problemas, se aplicó el proceso de normalización paso a paso:

### Primera Forma Normal (1FN)
* **Requisitos**: Todos los atributos deben ser atómicos (sin valores múltiples) y debe existir una clave primaria clara.
* **Aplicación**: 
  * Las celdas de la tabla plana ya contienen valores atómicos individuales.
  * Definimos claves primarias artificiales e incrementales (`ID`) para identificar de forma unívoca a los clientes, ciudades, productos, categorías y centros de distribución.
  * Los pedidos se separaron en una cabecera (`orders`) utilizando como clave primaria el identificador de orden (`order_id` ej. `O1001`) y el detalle individualizado de cada artículo comprado (`order_details`).

### Segunda Forma Normal (2FN)
* **Requisitos**: Debe cumplirse la 1FN y todos los atributos que no forman parte de la clave primaria deben depender por completo de esta clave (eliminación de dependencias parciales).
* **Aplicación**:
  * En la tabla de pedidos, atributos como la categoría del producto, el nombre del producto, el nombre del cliente, y el centro de distribución no dependían de la clave del pedido (`order_id`).
  * Se extrajeron las entidades independientes en sus propias tablas:
    * `clients` (Clientes)
    * `products` (Productos)
    * `categories` (Categorías)
    * `distribution_centers` (Centros de distribución)
  * Los detalles del pedido (`order_details`) ahora dependen de una clave compuesta implícita o una clave primaria `detail_id`, relacionándose directamente con la orden y el producto vendido.

### Tercera Forma Normal (3FN)
* **Requisitos**: Debe cumplirse la 2FN y no deben existir dependencias transitivas (ningún atributo no clave debe depender de otro atributo no clave).
* **Aplicación**:
  * La **Ciudad** (`cities`) determinaba transitivamente al **Centro de Distribución** (`distribution_centers`) que la atiende. No es el cliente o el pedido el que decide el centro de distribución, sino la ubicación geográfica de la ciudad.
  * Para resolver esto, se eliminó la columna de centro de distribución de los pedidos y los productos. En su lugar, se relacionó la tabla `cities` con la tabla `distribution_centers` mediante una clave foránea (`center_id`). De este modo, al conocer la ciudad del cliente se deduce automáticamente qué bodega regional provee el despacho, eliminando anomalías de actualización.
  * De igual manera, el **Cliente** se asocia directamente a una **Ciudad** de origen (o sucursal), eliminando la duplicación en cascada.

---

## 4. Modelo Normalizado Final

El diseño físico en la base de datos se estructuró con las siguientes 8 tablas sin prefijos y con nombres simples en inglés:

1. **`distribution_centers`**: Almacena los centros logísticos del país.
2. **`cities`**: Almacena las ciudades atendidas, enlazadas a su centro logístico correspondiente.
3. **`clients`**: Clientes homologados vinculados a su ciudad.
4. **`categories`**: Clasificación de productos (Frutas, Lácteos, Carnes, etc.).
5. **`products`**: Catálogo de productos con su categoría y precio unitario base.
6. **`inventories`**: Stock actual de cada producto en cada centro de distribución (clave compuesta).
7. **`orders`**: Cabecera de los pedidos (cliente y fecha).
8. **`order_details`**: Detalle de los artículos de cada orden (producto, cantidad y precio cobrado).

*Nota: El diagrama completo se encuentra disponible en formato vectorial en el archivo `modelo_entidad_relacion.svg`.*
