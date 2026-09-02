-- Descripciones de tablas y columnas de Northwind
--
-- Se guardan en el catálogo de PostgreSQL con COMMENT ON, así que viajan con la
-- base: un pg_dump se las lleva incluidas. Las lee cualquiera con permiso de
-- SELECT — comprobado con el rol alumnos — y DBeaver las muestra en la columna
-- Description del árbol de tablas.
--
-- CRITERIO DE REDACCIÓN
--   1. Dicen qué significa la cosa EN EL NEGOCIO, no de qué tipo es. El tipo ya
--      se ve; el significado, no.
--   2. NO revelan claves primarias, foráneas ni cardinalidades. Eso es lo que el
--      alumno tiene que deducir en `leer-un-esquema-desconocido`, y regalárselo
--      le quita el ejercicio.
--   3. Avisan de las trampas: columnas que parecen números y son texto, precios
--      que no son el precio que crees, booleanos que no son 0/1.
--   4. NUNCA llevan conteos ni cifras del contenido ("los 77 productos", "29
--      proveedores"). Esto es una base OLTP: las filas entran y salen, y el
--      comentario no se actualiza solo. Una cifra escrita aquí se convierte en
--      una mentira en cuanto alguien inserta o borra. El comentario describe QUÉ
--      ES la columna, no CUÁNTO hay hoy.
--
-- Es idempotente: se puede volver a ejecutar entero sin efectos secundarios.

-- ═══════════════════════════════════════════════════════════════════
-- BLOQUE 1 · EL CATÁLOGO — qué vende Northwind y a quién se lo compra
-- ═══════════════════════════════════════════════════════════════════

-- ── categories ─────────────────────────────────────────────────────
COMMENT ON TABLE categories IS
  'Familias en que Northwind agrupa su catálogo. Tabla de referencia: pequeña, estable y casi nunca cambia.';
COMMENT ON COLUMN categories.category_id IS
  'Identificador interno de la familia.';
COMMENT ON COLUMN categories.category_name IS
  'Nombre comercial de la familia, por ejemplo Beverages o Seafood.';
COMMENT ON COLUMN categories.description IS
  'Qué entra en esa familia, en texto libre. Es la definición de negocio más explícita que hay en toda la base.';

-- ── products ───────────────────────────────────────────────────────
COMMENT ON TABLE products IS
  'El catálogo de productos que Northwind compra a sus proveedores y revende. Incluye los descatalogados, que se conservan porque siguen apareciendo en pedidos antiguos.';
COMMENT ON COLUMN products.product_id IS
  'Identificador interno del producto.';
COMMENT ON COLUMN products.product_name IS
  'Nombre comercial tal como aparece en el catálogo.';
COMMENT ON COLUMN products.supplier_id IS
  'Proveedor al que Northwind le compra este producto.';
COMMENT ON COLUMN products.category_id IS
  'Familia del catálogo a la que pertenece el producto.';
COMMENT ON COLUMN products.quantity_per_unit IS
  'Formato de venta, en texto libre: "24 - 500 g pkgs.", "32 - 8 oz bottles". OJO: parece un dato numérico y no lo es. No se puede sumar ni comparar sin extraer antes las cifras.';
COMMENT ON COLUMN products.unit_price IS
  'Precio ACTUAL de catálogo. No es el precio al que se vendió: ese se guarda en cada línea de pedido, porque el precio cambia con el tiempo y la venta conserva el que tenía ese día.';
COMMENT ON COLUMN products.units_in_stock IS
  'Unidades disponibles en el almacén ahora mismo.';
COMMENT ON COLUMN products.units_on_order IS
  'Unidades ya pedidas al proveedor que todavía no han llegado.';
COMMENT ON COLUMN products.reorder_level IS
  'Umbral de reposición: por debajo de esta cantidad conviene volver a pedir. Comparado con units_in_stock responde qué productos hay que reponer.';
COMMENT ON COLUMN products.discontinued IS
  'Verdadero si el producto ya no se vende. TRAMPA: aquí es booleano, no 0/1. Las consultas de tutoriales de SQL Server usan "discontinued = 1" y en esta base fallan; se escribe "WHERE discontinued" o "WHERE NOT discontinued".';

-- ── suppliers ──────────────────────────────────────────────────────
COMMENT ON TABLE suppliers IS
  'Los proveedores a los que Northwind compra. Es el lado de las compras del negocio, el espejo de customers.';
COMMENT ON COLUMN suppliers.supplier_id IS
  'Identificador interno del proveedor.';
COMMENT ON COLUMN suppliers.company_name IS
  'Razón social del proveedor.';
COMMENT ON COLUMN suppliers.contact_name IS
  'Persona con la que se trata en esa empresa.';
COMMENT ON COLUMN suppliers.contact_title IS
  'Cargo de esa persona de contacto.';
COMMENT ON COLUMN suppliers.address IS
  'Dirección postal del proveedor.';
COMMENT ON COLUMN suppliers.city IS
  'Ciudad del proveedor.';
COMMENT ON COLUMN suppliers.region IS
  'Estado, provincia o región. Solo lo rellenan los países que usan ese nivel administrativo, así que está vacío a menudo. Buen sitio para tropezar con NULL por primera vez.';
COMMENT ON COLUMN suppliers.postal_code IS
  'Código postal, en texto porque los formatos cambian según el país y algunos llevan letras.';
COMMENT ON COLUMN suppliers.country IS
  'País del proveedor.';
COMMENT ON COLUMN suppliers.phone IS
  'Teléfono de contacto, sin formato normalizado.';
COMMENT ON COLUMN suppliers.fax IS
  'Fax. No todos lo tienen: los datos son de los años noventa y se nota.';
COMMENT ON COLUMN suppliers.homepage IS
  'Página web del proveedor. Suele estar vacío y, cuando existe, con formato irregular.';

-- ═══════════════════════════════════════════════════════════════════
-- BLOQUE 2 · LAS VENTAS — quién compra, qué pide y en qué condiciones
-- ═══════════════════════════════════════════════════════════════════

-- ── customers ──────────────────────────────────────────────────────
COMMENT ON TABLE customers IS
  'Los clientes de Northwind: tiendas gourmet, delicatessen y restaurantes que compran al por mayor para revender. Nunca son personas comprando para su casa.';
COMMENT ON COLUMN customers.customer_id IS
  'Código del cliente. TRAMPA: no es un número, es un texto de cinco letras derivado del nombre de la empresa (ALFKI, ANATR). Ordenar por él ordena alfabéticamente, no por antigüedad.';
COMMENT ON COLUMN customers.company_name IS
  'Razón social del cliente. Es el nombre con el que se le conoce en los informes.';
COMMENT ON COLUMN customers.contact_name IS
  'Persona con la que se trata en esa empresa.';
COMMENT ON COLUMN customers.contact_title IS
  'Cargo de esa persona de contacto. Dice con quién se negocia: no es lo mismo tratar con el dueño que con quien hace los pedidos.';
COMMENT ON COLUMN customers.address IS
  'Dirección fiscal del cliente, la actual. La de entrega de cada pedido se guarda aparte, en el propio pedido.';
COMMENT ON COLUMN customers.city IS
  'Ciudad del cliente.';
COMMENT ON COLUMN customers.region IS
  'Estado, provincia o región. Solo lo rellenan los países que usan ese nivel administrativo, así que está vacío a menudo.';
COMMENT ON COLUMN customers.postal_code IS
  'Código postal, en texto porque los formatos cambian según el país.';
COMMENT ON COLUMN customers.country IS
  'País del cliente. Es la columna con la que se mira el negocio por mercados.';
COMMENT ON COLUMN customers.phone IS
  'Teléfono de contacto, sin formato normalizado.';
COMMENT ON COLUMN customers.fax IS
  'Fax. No todos lo tienen.';

-- ── orders ─────────────────────────────────────────────────────────
COMMENT ON TABLE orders IS
  'La cabecera de cada pedido: quién lo hizo, quién lo atendió, cuándo y a dónde va. Lo que se pidió no está aquí, sino en order_details.';
COMMENT ON COLUMN orders.order_id IS
  'Identificador del pedido. Es el número que el cliente ve en su factura.';
COMMENT ON COLUMN orders.customer_id IS
  'Cliente que hizo el pedido.';
COMMENT ON COLUMN orders.employee_id IS
  'Empleado que registró el pedido. Es lo que permite mirar las ventas por comercial.';
COMMENT ON COLUMN orders.order_date IS
  'Fecha en que se registró el pedido. Es la fecha de referencia para cualquier análisis temporal de ventas.';
COMMENT ON COLUMN orders.required_date IS
  'Fecha en que el cliente necesita recibirlo. Es un compromiso, no un hecho: comparada con shipped_date dice si se cumplió.';
COMMENT ON COLUMN orders.shipped_date IS
  'Fecha en que el pedido salió del almacén. Vacío mientras no ha salido, y ese vacío significa "todavía pendiente", no "dato que se perdió". Distinguir esos dos vacíos es media carrera de analista.';
COMMENT ON COLUMN orders.ship_via IS
  'Transportista al que se encarga el envío. Se llama ship_via y no shipper_id: el mismo concepto tiene nombre distinto a cada lado, y eso pasa en cualquier base real.';
COMMENT ON COLUMN orders.freight IS
  'Coste del transporte de este pedido. Es del pedido entero, no de cada producto: para repartirlo entre las líneas hay que decidir un criterio, y no hay uno correcto.';
COMMENT ON COLUMN orders.ship_name IS
  'Nombre al que se envía, tal como estaba el día del pedido. Copiado aquí a propósito: si el cliente cambia de nombre, los pedidos antiguos deben seguir diciendo a quién se envió de verdad.';
COMMENT ON COLUMN orders.ship_address IS
  'Dirección de entrega congelada en el momento del pedido. Puede no coincidir con la dirección actual del cliente, y eso no es un error: es el histórico.';
COMMENT ON COLUMN orders.ship_city IS
  'Ciudad de entrega en el momento del pedido.';
COMMENT ON COLUMN orders.ship_region IS
  'Región de entrega en el momento del pedido. Vacío a menudo, igual que en el cliente.';
COMMENT ON COLUMN orders.ship_postal_code IS
  'Código postal de entrega en el momento del pedido.';
COMMENT ON COLUMN orders.ship_country IS
  'País de entrega en el momento del pedido. Para analizar a dónde se envía se usa este; para saber de dónde es el cliente, el de su ficha.';

-- ── order_details ──────────────────────────────────────────────────
COMMENT ON TABLE order_details IS
  'El detalle de los pedidos: qué productos lleva cada uno y en qué condiciones se vendieron. Aquí es donde está el dinero — la facturación no se guarda en ninguna columna, se calcula a partir de esta tabla.';
COMMENT ON COLUMN order_details.order_id IS
  'Pedido al que pertenece esta línea.';
COMMENT ON COLUMN order_details.product_id IS
  'Producto que se vendió en esta línea.';
COMMENT ON COLUMN order_details.unit_price IS
  'Precio al que se vendió ese día. Es el histórico y no cambia nunca; el precio vigente del catálogo vive en products y sí cambia. Para facturar se usa este, siempre.';
COMMENT ON COLUMN order_details.quantity IS
  'Unidades vendidas de ese producto en esta línea.';
COMMENT ON COLUMN order_details.discount IS
  'Descuento aplicado, expresado como fracción entre cero y uno: 0.25 significa un veinticinco por ciento. TRAMPA: no es un porcentaje ni un importe. El importe de la línea sale de unit_price * quantity * (1 - discount).';

-- ═══════════════════════════════════════════════════════════════════
-- BLOQUE 3 · LA EMPRESA — quién trabaja aquí y quién mueve la mercancía
-- ═══════════════════════════════════════════════════════════════════

-- ── employees ──────────────────────────────────────────────────────
COMMENT ON TABLE employees IS
  'La plantilla de Northwind. Es una empresa pequeña, así que casi todos aparecen atendiendo pedidos: mirar las ventas por empleado es mirar a personas concretas, no a departamentos.';
COMMENT ON COLUMN employees.employee_id IS
  'Identificador interno del empleado.';
COMMENT ON COLUMN employees.last_name IS
  'Apellido. Va en columna aparte del nombre, así que para mostrar el nombre completo hay que unir las dos.';
COMMENT ON COLUMN employees.first_name IS
  'Nombre de pila.';
COMMENT ON COLUMN employees.title IS
  'Cargo dentro de la empresa. Es lo que distingue a quien vende de quien dirige o coordina.';
COMMENT ON COLUMN employees.title_of_courtesy IS
  'Tratamiento de cortesía (Mr., Ms., Dr.). Sirve para redactar cartas, no para analizar nada.';
COMMENT ON COLUMN employees.birth_date IS
  'Fecha de nacimiento. Es dato personal: aparece porque el dataset es de práctica, no porque una base real deba mostrárselo a cualquiera.';
COMMENT ON COLUMN employees.hire_date IS
  'Fecha de incorporación a la empresa. Comparada con la fecha de los pedidos dice cuánta experiencia tenía quien los atendió.';
COMMENT ON COLUMN employees.address IS
  'Domicilio del empleado.';
COMMENT ON COLUMN employees.city IS
  'Ciudad del empleado.';
COMMENT ON COLUMN employees.region IS
  'Estado, provincia o región del empleado. Vacío cuando el país no usa ese nivel.';
COMMENT ON COLUMN employees.postal_code IS
  'Código postal del domicilio del empleado.';
COMMENT ON COLUMN employees.country IS
  'País del empleado. Ojo al compararlo con el país del cliente: no tienen por qué coincidir, y de hecho no coinciden.';
COMMENT ON COLUMN employees.home_phone IS
  'Teléfono particular del empleado.';
COMMENT ON COLUMN employees.extension IS
  'Extensión telefónica interna. Es texto, no número: puede empezar por cero y no se suma nunca.';
COMMENT ON COLUMN employees.notes IS
  'Biografía del empleado en texto libre y en párrafos. Es la columna más larga de la base y no se puede agrupar ni comparar: solo leer o buscar dentro.';
COMMENT ON COLUMN employees.reports_to IS
  'Empleado del que depende esta persona. Está vacío en quien no depende de nadie, y ese vacío es el que marca la cima del organigrama.';

-- ── shippers ───────────────────────────────────────────────────────
COMMENT ON TABLE shippers IS
  'Las empresas de transporte que llevan los pedidos. Northwind no tiene flota propia: subcontrata, y por eso el transporte es un proveedor más y no un coste interno.';
COMMENT ON COLUMN shippers.shipper_id IS
  'Identificador interno del transportista. Se llama shipper_id aquí, pero en el pedido la columna que lo usa se llama ship_via.';
COMMENT ON COLUMN shippers.company_name IS
  'Nombre de la empresa de transporte.';
COMMENT ON COLUMN shippers.phone IS
  'Teléfono de contacto del transportista.';

-- ═══════════════════════════════════════════════════════════════════
-- BLOQUE 4 · LA GEOGRAFÍA COMERCIAL — cómo se reparte la fuerza de ventas
-- ═══════════════════════════════════════════════════════════════════

-- ── region ─────────────────────────────────────────────────────────
COMMENT ON TABLE region IS
  'Las grandes zonas en que se divide el territorio comercial: Eastern, Western, Northern y Southern. Es geografía de ventas de Estados Unidos, no del mundo — y Northwind vende en muchos más países de los que este mapa cubre.';
COMMENT ON COLUMN region.region_id IS
  'Identificador interno de la zona.';
COMMENT ON COLUMN region.region_description IS
  'Nombre de la zona comercial.';

-- ── territories ────────────────────────────────────────────────────
COMMENT ON TABLE territories IS
  'Los territorios de venta, el nivel de detalle por debajo de la zona. Sirven para repartir la cartera entre comerciales, no para localizar clientes: un cliente no tiene territorio.';
COMMENT ON COLUMN territories.territory_id IS
  'Código del territorio. TRAMPA: parece un número pero es texto, y a veces trae ceros a la izquierda que se pierden si alguien lo convierte a entero.';
COMMENT ON COLUMN territories.territory_description IS
  'Nombre del territorio, normalmente una ciudad o comarca.';
COMMENT ON COLUMN territories.region_id IS
  'Zona comercial a la que pertenece el territorio.';

-- ── employee_territories ───────────────────────────────────────────
COMMENT ON TABLE employee_territories IS
  'Qué comercial atiende qué territorio. Es una tabla puente: no guarda ningún dato propio, solo empareja las dos cosas — y existe porque un comercial lleva varios territorios y un territorio puede tocar a varios comerciales.';
COMMENT ON COLUMN employee_territories.employee_id IS
  'Comercial asignado.';
COMMENT ON COLUMN employee_territories.territory_id IS
  'Territorio que atiende.';

-- ── us_states ──────────────────────────────────────────────────────
COMMENT ON TABLE us_states IS
  'Catálogo de estados de Estados Unidos con su abreviatura. ATENCIÓN: ninguna columna de la base apunta a esta tabla — está en el esquema pero no está conectada a nada. Encontrar tablas huérfanas así es normal en bases reales, y saber detectarlas antes de usarlas evita informes construidos sobre un dato que nadie mantiene.';
COMMENT ON COLUMN us_states.state_id IS
  'Identificador interno del estado.';
COMMENT ON COLUMN us_states.state_name IS
  'Nombre completo del estado.';
COMMENT ON COLUMN us_states.state_abbr IS
  'Abreviatura de dos letras del estado.';
COMMENT ON COLUMN us_states.state_region IS
  'Zona del país a la que se adscribe el estado.';
