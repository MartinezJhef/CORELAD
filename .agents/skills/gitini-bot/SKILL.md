---
name: gitini-bot
description: >-
  Inicializa y prepara el ciclo de vida de un Caso de Uso en Git y GitHub para el Sistema Integral CORLAD Junín.
  Analiza los requisitos desde los documentos oficiales, extrae el código y nombre del Caso de Uso, genera los
  criterios de aceptación y el checklist de tareas técnicas por capas, crea el GitHub Issue oficial, lo asigna
  al GitHub Project en la columna POR HACER, crea la rama Git de trabajo (feature/cu-...) y la mueve a EN PROGRESO,
  dejando la posta lista para /arbol-bot. Se activa explícitamente con el comando /gitini-bot.
---

# SKILL: /gitini-bot – Gestor de Apertura de Caso de Uso, Git Branching & GitHub Project

Esta skill rige el comportamiento de Antigravity como **Lead Scrum Master & Git Project Initializer** para el **Sistema Integrado de Gestión Institucional del Colegio Regional de Licenciados en Administración de Junín (CORLAD Junín)**.

---

## 1. MISIÓN Y PUNTO DE PARTIDA

El bot se activa cuando el usuario invoca `/gitini-bot` (o solicita iniciar un nuevo caso de uso, preparar el repositorio Git, crear la rama de trabajo, abrir un Issue en GitHub o preparar el tablero del proyecto antes de programar).

> [!IMPORTANT]
> **PUNTO DE INICIO DEL CICLO DE VIDA COMPLETO:**  
> `/gitini-bot` es el **primer bot de la cadena de desarrollo**. Su responsabilidad es preparar todo el ecosistema de trabajo en Git y GitHub para que el equipo técnico (`/arbol-bot`, `/back-bot`, `/front-bot`, etc.) trabaje sobre una rama aislada, con requerimientos claros, tareas técnicas definidas y trazabilidad garantizada desde el minuto cero.

```text
                 ┌──────────────────────────────────────┐
                 │     NUEVO REQUERIMIENTO / CU         │
                 │   (ej: CU-COL-01, CU-HAB-02, etc.)   │
                 └──────────────────┬───────────────────┘
                                    │
                                    ▼
                             /gitini-bot
                 (Apertura, Issue, Branch, Project)
                                    │
                                    ▼
                              /arbol-bot
                     (Estructura y Contratos)
                                    │
                                    ▼
                              /back-bot
                       (Backend VB.NET N-Tier)
                                    │
                                    ▼
                              /front-bot
                        (Frontend React + GSAP)
                                    │
                                    ▼
                               /ui-bot
                     (Design System & Responsive)
                                    │
                                    ▼
                               /qa-bot
                      (18 Dimensiones de Tests)
                                    │
                                    ▼
                               /iso-bot
                     (Certificación ISO/IEC 25010)
                                    │
                                    ▼
                              /gitfin-bot
                     (PR, Merge, Cierre y Reporte)
```

---

## 2. FLUJO OPERATIVO PASO A PASO DE `/gitini-bot`

Antes de programar o estructurar el caso de uso, `/gitini-bot` ejecuta estrictamente estos 6 pasos:

```text
CASO DE USO
    │
    ▼
1. Analizar requisitos y extraer nomenclatura oficial
    │
    ▼
2. Generar criterios de aceptación (Checklist)
    │
    ▼
3. Crear GitHub Issue formal con tareas técnicas por capas
    │
    ▼
4. Agregar al GitHub Project ──► 📋 POR HACER
    │
    ▼
5. Crear y activar rama Git: git checkout -b feature/[cu]-[nombre]
    │
    ▼
6. Actualizar GitHub Project ──► 🟡 EN PROGRESO
    │
    ▼
7. ENTREGA FORMAL A /arbol-bot
```

---

### Paso 1: Extracción y Nomenclatura desde Documentos Oficiales
`/gitini-bot` consulta **obligatoriamente** las fuentes normativas del proyecto:
- `DOCUMENTOS INTERNOS CORLAD/3.CASOS_DE_USO_SISTEMA_INTEGRAL_CORLAD.md`
- `DOCUMENTOS INTERNOS CORLAD/2.HISTORIAS_DE_USUARIO_SISTEMA_INTEGRAL_CORLAD.md`
- `DOCUMENTOS INTERNOS CORLAD/1.REQUERIMIENTOS_FUNCIONALES_SISTEMA_INTEGRAL_CORLAD.md`

Extrae de forma estandarizada:
- **Código Oficial:** `CU-[MOD]-[NUM]` (ej: `CU-COL-01`, `CU-COL-02`, `CU-HAB-01`, `CU-HAB-02`, `CU-TES-01`, `CU-SGD-01`).
- **Nombre Institucional:** Nombre formal según la especificación Cockburn del documento.
- **Actor Principal:** Rol institucional autorizado (ej: `Postulante a Colegiatura`, `Secretaria Regional`, `Tesorera`, `Colegiado Agremiado`).
- **Objetivo:** Propósito de negocio en el CORLAD Junín.
- **Precondición:** Estado que debe cumplirse antes de la ejecución.
- **Resultado:** Efecto final persistido en el sistema.

---

### Paso 2: Generación de Criterios de Aceptación
Establece los criterios de aceptación inequívocos en formato checklist (`[ ]`):
```markdown
### Criterios de Aceptación:
- [ ] El actor puede acceder al formulario o vista oficial desde la interfaz.
- [ ] El sistema valida campos requeridos y formatos obligatorios (DNI 8 dígitos, RUC 11 dígitos, montos mayores a S/. 0.00).
- [ ] El sistema ejecuta las reglas de negocio institucionales (validación en padrón, control de cuotas, estado de habilidad).
- [ ] La interfaz cumple rigurosamente los tokens cromáticos oficiales (#007030, #F5A604) y hereda de `components/base/`.
- [ ] Las consultas a base de datos están protegidas contra SQL Injection usando parámetros tipados `SqlParameter`.
- [ ] El usuario recibe retroalimentación visual clara (loaders durante peticiones, notificaciones toast y modales).
- [ ] La operación queda auditada con fecha, hora, usuario y hash en SQL Server 2026.
```

---

### Paso 3: Estructura Oficial del GitHub Issue
Crea el Issue formal en el repositorio con el siguiente contenido técnico detallado:

```markdown
# [Código CU] - [Nombre Oficial del Caso de Uso]

## 📋 Descripción del Requerimiento
[Objetivo del Caso de Uso, justificación institucional y actores involucrados]

## 🎯 Criterios de Aceptación
[Checklist detallado de criterios del Paso 2]

## 🛠️ Tareas Técnicas por Capas (Arquitectura N-Tier & React)
- [ ] **1. Base de Datos:** Verificar tablas, llaves foráneas (`FK_`) y restricciones (`CK_`) en `CORLADJunin2026_SQLServer.sql`.
- [ ] **2. Capa Negocios (Entidades):** Crear entidad POCO `[Entidad]BE.vb` y `[Operacion]FormRequest.vb` con método `Authorize(rol)`.
- [ ] **3. Capa Acceso a Datos:** Declarar `I[Entidad]AccesoDatos.vb` e implementar `[Entidad]AccesoDatos.vb` con `SqlHelper` parametrizado.
- [ ] **4. Capa Negocios (Flujo de Trabajo):** Declarar `I[Entidad]Servicio.vb` e implementar reglas en `[Entidad]FlujoTrabajo.vb`.
- [ ] **5. Capa Presentación (API):** Crear controlador REST `[Entidad]Controller.vb` con respuestas en `ApiResponse(Of T)`.
- [ ] **6. Frontend (React):** Crear vistas modulares en `features/[mod]/` heredando de `components/base/` y tokens oficiales.
- [ ] **7. Frontend (Hooks y Servicios):** Crear `use[Entidad].js` y servicio Axios con interceptores Bearer JWT.
- [ ] **8. Pruebas Automatizadas:** Cobertura de pruebas unitarias xUnit/Vitest, E2E con Playwright y carga con k6.

## 🔗 Trazabilidad Institucional
- **Módulo:** `[ADM / CAJ / CLI / CNT / GEN / GRH / LOG / MLA / PRE / RPT]`
- **Caso de Uso:** `[Código CU]`
- **Historia de Usuario Vinculada:** `[Código HU]`
- **Requerimiento Funcional:** `[Código RF]`
```

---

### Paso 4: Tablero GitHub Project (`📋 POR HACER`)
El Issue creado se añade automáticamente a la columna inicial del GitHub Project:

```text
┌─────────────────┬─────────────────┬─────────────────┐
│   POR HACER     │   EN PROGRESO   │      HECHO      │
├─────────────────┼─────────────────┼─────────────────┤
│ [Código CU]  📌 │                 │                 │
└─────────────────┴─────────────────┴─────────────────┘
```

---

### Paso 5: Creación y Activación de la Rama Git
Genera la rama de trabajo aislada siguiendo la nomenclatura semántica obligatoria:

```bash
# Formato: feature/[codigo-cu-minusculas]-[descripcion-kebab-case]
git checkout -b feature/[codigo-cu]-[nombre-kebab-case]

# Ejemplos institucionales reales:
git checkout -b feature/cu-col-01-solicitar-preinscripcion
git checkout -b feature/cu-hab-02-emitir-constancia-habilidad
git checkout -b feature/cu-tes-01-registrar-cobro-ventanilla
git checkout -b feature/cu-caj-02-emitir-factura-electronica
```

---

### Paso 6: Actualización del Estado en GitHub Project (`🟡 EN PROGRESO`)
Una vez creada la rama, `/gitini-bot` mueve automáticamente la tarjeta en el tablero Kanban:

```text
┌─────────────────┬─────────────────┬─────────────────┐
│   POR HACER     │   EN PROGRESO   │      HECHO      │
├─────────────────┼─────────────────┼─────────────────┤
│                 │ [Código CU]  🟡 │                 │
└─────────────────┴─────────────────┴─────────────────┘
```

---

## 3. MENSAJE FINAL OBLIGATORIO DE ENTREGA (PASE A `/arbol-bot`)

Al concluir la preparación en Git y GitHub, `/gitini-bot` **debe concluir obligatoriamente con este bloque formal de entrega estandarizado**:

```markdown
---

### 🚀 MENSAJE DE PASE AL SIGUIENTE BOT (FASE DE ESTRUCTURACIÓN ARQUITECTÓNICA)
> [!NOTE]
> ### 🏁 **¡CASO DE USO INICIALIZADO Y PREPARADO EN GIT / GITHUB!**  
> Se han extraído los requerimientos normativos oficiales, creado el GitHub Issue con sus criterios de aceptación y tareas técnicas por capas, registrado la tarjeta en el GitHub Project y activado la rama de trabajo aislada.  
>  
> 📌 **DETALLES DEL CASO DE USO INICIALIZADO:**  
> - **Caso de Uso:** `[Código CU]: [Nombre Oficial]`  
> - **Módulo:** `[Código Módulo, ej: CLI / CAJ / SGD]`  
> - **Actor Principal:** `[Nombre del Actor]`  
> - **GitHub Issue:** `#[Número de Issue]` (Asignado en GitHub Project: `🟡 EN PROGRESO`)  
> - **Rama Git Activa:** `feature/[codigo-cu]-[nombre-kebab-case]`  
> - **Criterios de Aceptación:** `[Número de criterios, ej: 7]` definidos en checklist  
>  
> 📋 **INSTRUCCIÓN PARA EL SIGUIENTE BOT (ARBOL-BOT / ARQUITECTO ESTRUCTURAL):**  
> *"Toma este Caso de Uso inicializado con su rama de trabajo activa y requerimientos definidos en el Issue #[Número], y procede a estructurar la arquitectura N-Tier en Visual Basic .NET (Entidades DTO, Interfaces, Acceso a Datos, Flujo de Trabajo y Controladores REST) sin programar código, cruzando las 5 fuentes documentales."*
```
