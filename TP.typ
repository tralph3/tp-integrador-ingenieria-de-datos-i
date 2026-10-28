#set document(title: "TP Integrador - Base de Datos", author: "Grupo 14")
#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
  number-align: center,
)
#set text(lang: "es", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.")
#show heading.where(level: 1): it => {
  v(1em)
  it
  v(0.4em)
}
#show raw.where(block: true): it => block(
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
  it,
)

// ---------------------------------------------------------------- Carátula
#page(numbering: none)[
  #align(center)[
    #v(1fr)
    #text(size: 14pt)[Universidad Argentina de la Empresa (UADE)] \
    #text(size: 12pt)[Ingeniería de Datos 1 · 2do Cuatrimestre 2026]

    #v(2cm)
    #text(size: 24pt, weight: "bold")[Trabajo Práctico Integrador] \
    #v(0.3cm)
    #text(size: 16pt)[Base de Datos: Concesionaria de Automóviles]

    #v(2cm)
    #line(length: 60%)
    #v(0.5cm)

    *Docentes* \
    Lic. Gustavo E. Escandell \
    Ing. Melinda Selles

    #v(1cm)
    *Grupo:* Nº 14

    #v(1fr)
    Fecha de entrega: 5 de noviembre de 2026
  ]
]

// ------------------------------------------------------------- Integrantes
#page(numbering: none)[
  #heading(numbering: none)[Integrantes]

  #table(
    columns: (1fr, auto, 1.5fr),
    align: (left, center, left),
    stroke: 0.5pt + luma(150),
    inset: 7pt,
    table.header[*Nombre y apellido*][*Legajo*][*Rama de Git*],
    [Tomás Ralph], [1248335], [`ralph`],
    [Augusto Lecour], [1216511], [`lecour`],
  )

  #v(1em)
  *Repositorio:* `https://github.com/tralph3/tp-integrador-ingenieria-de-datos-i`
]

// ------------------------------------------------------------------ Índice
#page(numbering: none)[
  #outline(title: "Índice", indent: auto, depth: 2)
]

#counter(page).update(1)

// --------------------------------------------------------------- Contenido
= Descripción del sistema
Descripción general de la concesionaria y del problema que resuelve la base
de datos. _Placeholder._

= Universo del Discurso
== Contexto del sistema
_Placeholder._
== Objetivo de la base de datos
_Placeholder._
== Actores involucrados
_Placeholder._
== Procesos principales
_Placeholder._

= Reglas de negocio
+ Al realizar una venta, el cliente debe ser mayor de 18 años.
+ Todas las ventas deben estar registradas a un vendedor.
+ El vehículo debe registrarse a nombre del cliente en el RUNA.

= Diagrama Entidad-Relación
#figure(
  rect(width: 100%, height: 6cm, stroke: (dash: "dashed"))[
    #align(center + horizon)[_Insertar imagen del DER_]
  ],
  caption: [Diagrama Entidad-Relación.],
)

= Proceso de normalización
== Dependencias funcionales y claves candidatas
_Placeholder._
== Formas normales (1FN a 5FN)
_Placeholder._

= Modelo de tablas
```sql
CREATE TABLE ejemplo (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);
```

= Diccionario de datos
#table(
  columns: (auto, auto, auto, 1fr),
  stroke: 0.5pt + luma(150),
  inset: 6pt,
  table.header[*Tabla*][*Campo*][*Tipo*][*Descripción*],
  [`clientes`], [`id`], [`INT`], [Identificador del cliente.],
  [`clientes`], [`dni`], [`VARCHAR(20)`], [Documento, único.],
)

= Consultas SQL
_Placeholder._

= Subconsultas
_Placeholder: qué información se obtiene, qué función cumple la subconsulta y por qué es adecuada._

= Vistas
_Placeholder: objetivo, información presentada, tablas involucradas y motivo._

= Stored Procedures
_Placeholder._

= Triggers
_Placeholder: evento, tabla, condición, acción y regla de negocio._

= Cursores
_Placeholder: problema, motivo, registros procesados y operación por registro._

= Funciones
_Placeholder: objetivo, parámetros, tipo de retorno, lógica y ejemplo._

= Manejo de errores
_Placeholder._

= Seguridad de la base de datos
_Placeholder: usuarios, roles, permisos y protección de información sensible._

= Centralización de la lógica en la capa de datos
_Placeholder._

= Conclusiones
_Placeholder._
