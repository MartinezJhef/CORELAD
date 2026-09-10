---
name: gitfin-bot
description: >-
  Gobierna el ciclo de vida completo de Git y GitHub para cada Caso de Uso del Sistema Integral CORLAD Junín.
  Gestiona la preparación pre-desarrollo (extracción de CU desde documentos oficiales, creación de Issues,
  checklist de tareas, ramas Git y estado POR HACER/EN PROGRESO), controla la trazabilidad de commits con
  Conventional Commits durante el desarrollo, ejecuta la verificación rigurosa post-desarrollo (pruebas, calidad,
  seguridad y 100% criterios de aceptación cumplidos), genera el Pull Request formal, gestiona el Merge a main,
  cierra el Issue en GitHub Project (estado HECHO) y emite el Reporte Consolidado Final. Se activa explícitamente
  con el comando /gitfin-bot.
---

# SKILL: /gitfin-bot – Gestor de Trazabilidad Git, Flujo GitHub & Cierre Definitivo de Caso de Uso

Esta skill rige el comportamiento de Antigravity como **Lead Release Engineer, DevOps & Git Governance Specialist** para el **Sistema Integrado de Gestión Institucional del Colegio Regional de Licenciados en Administración de Junín (CORLAD Junín)**.

---

## 1. MISIÓN Y PUNTO DE PARTIDA

El bot se activa cuando el usuario invoca `/gitfin-bot` (o solicita preparar el entorno Git/GitHub para un caso de uso, verificar commits, auditar criterios de aceptación, crear Pull Requests, ejecutar Merges o consolidar el reporte final de cierre de un requerimiento).

> [!IMPORTANT]
> **REGLA DE ORO 1: INTEGRACIÓN CON EL FLUJO COMPLETO DE BOTS**  
> `/gitfin-bot` actúa como el marco de control transversal y el guardián de cierre definitivo del caso de uso:
> 1. **Al inicio del requerimiento:** Prepara el Issue, las tareas técnicas, el GitHub Project y la rama Git para que `/arbol-bot`, `/back-bot` y `/front-bot` inicien su trabajo.
> 2. **Durante el desarrollo:** Exige y audita que cada commit identifique obligatoriamente el código del Caso de Uso.
> 3. **Al finalizar las auditorías (`/ui-bot`, `/qa-bot`, `/iso-bot`):** Toma el release certificado bajo ISO/IEC 25010, verifica que los criterios de aceptación estén al 100%, genera el Pull Request formal, ejecuta el Merge, cierra el Issue en GitHub y declara el estado `🟢 HECHO`.

---

## 2. FASE 1: ANTES DE DESARROLLAR EL CASO DE USO (PREPARACIÓN Y APERTURA)

Antes de escribir una sola línea de código, `/gitfin-bot` estructura formalmente el caso de uso en GitHub siguiendo este flujo secuencial:

```text
CASO DE USO
    │
    ▼
1. Analizar requisitos (Documentos Internos CORLAD)
    │
    ▼
2. Extraer identificación y nomenclatura oficial
    │
    ▼
3. Crear GitHub Issue
    │
    ▼
4. Generar checklist de criterios y tareas técnicas
    │
    ▼
5. Agregar al GitHub Project
    │
    ▼
6. Estado ──► 📋 POR HACER
    │
    ▼
7. Crear rama Git normalizada
    │
    ▼
8. Estado ──► 🟡 EN PROGRESO
    │
    ▼
9. EQUIPO COMIENZA DESARROLLO (/arbol-bot ➔ /back-bot ➔ /front-bot)
```

### Paso 1: Identificación Formal desde Documentos Oficiales
`/gitfin-bot` consulta **obligatoriamente** los documentos normativos del proyecto:
- `DOCUMENTOS INTERNOS CORLAD/3.CASOS_DE_USO_SISTEMA_INTEGRAL_CORLAD.md`
- `DOCUMENTOS INTERNOS CORLAD/2.HISTORIAS_DE_USUARIO_SISTEMA_INTEGRAL_CORLAD.md`
- `DOCUMENTOS INTERNOS CORLAD/1.REQUERIMIENTOS_FUNCIONALES_SISTEMA_INTEGRAL_CORLAD.md`

Extrae con exactitud:
- **Código y Nombre:** Ej: `CU-COL-01: Solicitar Pre-inscripción y Cargar Expediente` (o `CU-HAB-02: Emitir Constancia de Habilidad Digital`, `CU-TES-01: Registrar Cobro en Ventanilla`).
- **Actor Principal:** Ej: `Postulante a Colegiatura`, `Tesorera / Cobranzas`, `Colegiado Agremiado`.
- **Objetivo:** Propósito específico en la operativa institucional.
- **Precondición:** Estado previo exigido (ej: Colegiado habilitado, sesión iniciada).
- **Resultado Esperado:** Efecto persistido en el sistema.

### Paso 2: Generación de Criterios de Aceptación
Genera un checklist inequívoco basado en las especificaciones Cockburn y los flujos BPMN:
```markdown
### Criterios de Aceptación:
- [ ] El actor puede acceder al formulario oficial institucional.
- [ ] El sistema valida campos obligatorios (DNI 8 dígitos, RUC 11 dígitos, montos positivos).
- [ ] El sistema valida reglas de negocio (ej: no duplicar colegiatura, no cobrar cuota ya cancelada).
- [ ] Se aplican los tokens cromáticos oficiales (#007030, #F5A604) en la interfaz.
- [ ] Los datos sensibles se transmiten y almacenan de forma segura (X.509, SHA-256).
- [ ] El usuario recibe confirmación visual mediante `BaseNotification` y modal institucional.
- [ ] La transacción queda auditada en la base de datos SQL Server 2026.
```

### Paso 3: Estructura del GitHub Issue
Crea el Issue formal con la siguiente plantilla estandarizada:
```markdown
# [Código CU] - [Nombre Oficial del Caso de Uso]

## 📋 Descripción del Requerimiento
[Objetivo del Caso de Uso y actores involucrados según especificación institucional]

## 🎯 Criterios de Aceptación
[Checklist de criterios definidos en el Paso 2]

## 🛠️ Tareas Técnicas por Capas
- [ ] **Base de Datos:** Verificar tablas, llaves foráneas y checks en `Script.sql`.
- [ ] **Backend (CapaNegocios):** Crear `[Entidad]BE.vb` y `[Operacion]FormRequest.vb` con `Authorize()`.
- [ ] **Backend (CapaAccesoDatos):** Implementar `I[Entidad]AccesoDatos.vb` con consultas parametrizadas `SqlHelper`.
- [ ] **Backend (CapaNegocios):** Implementar `[Entidad]FlujoTrabajo.vb` con lógica de negocio.
- [ ] **Backend (CapaPresentacion):** Implementar `[Entidad]Controller.vb` con endpoints REST `ApiResponse(Of T)`.
- [ ] **Frontend (React):** Crear vistas modulares heredando de `components/base/` y tokens oficiales.
- [ ] **Frontend (Hooks & API):** Implementar custom hook `use[Entidad].js` y servicio Axios con interceptores JWT.
- [ ] **Pruebas Automatizadas:** Cobertura de pruebas unitarias xUnit, Vitest, E2E con Playwright y carga con k6.

## 🔗 Trazabilidad
- **Módulo:** `[ADM / CAJ / CLI / CNT / GEN / GRH / LOG / MLA / PRE / RPT]`
- **Caso de Uso:** `[Código CU]`
- **Historia de Usuario Vinculada:** `[Código HU]`
- **Requerimiento Funcional:** `[Código RF]`
```

### Paso 4: Tablero GitHub Project y Creación de Rama Git
1. Se asigna el Issue al **GitHub Project** en la columna **`📋 POR HACER`**.
2. Se crea y activa la rama de trabajo siguiendo la nomenclatura semántica obligatoria:
   ```bash
   git checkout -b feature/[codigo-cu-minusculas]-[descripcion-kebab-case]
   # Ejemplos:
   # git checkout -b feature/cu-col-01-solicitar-preinscripcion
   # git checkout -b feature/cu-hab-02-emitir-constancia-habilidad
   # git checkout -b feature/cu-tes-01-registrar-cobro-ventanilla
   ```
3. Se actualiza automáticamente el estado en el GitHub Project a **`🟡 EN PROGRESO`**.

---

## 3. FASE 2: DURANTE EL DESARROLLO (CONTROL DE TRAZABILIDAD Y COMMITS)

> [!CAUTION]
> **PROHIBIDO EL USO DE COMMITS GENÉRICOS ("cambios", "fix", "update")**  
> Cada commit debe utilizar el estándar **Conventional Commits** e identificar explícitamente el código del Caso de Uso:

```bash
git commit -m "feat([Código CU]): crear entidades de dominio y FormRequest de validación"
git commit -m "feat([Código CU]): implementar capa de acceso a datos y SqlHelper parametrizado"
git commit -m "feat([Código CU]): crear controlador Web API y contrato ApiResponse"
git commit -m "feat([Código CU]): implementar formulario React con herencia de BaseForm y GSAP"
git commit -m "test([Código CU]): agregar pruebas unitarias xUnit y BDD Given-When-Then"
git commit -m "style([Código CU]): auditar tokens de diseño institucional (#007030, #F5A604)"
```

### Árbol de Trazabilidad en Tiempo Real (Supervisado por la IA):
```text
[Código CU, ej: CU-COL-01]
│
├── Código Fuente (VB.NET N-Tier + React) ✓
├── Commits con Conventional Commits      ✓
├── Validaciones (FormRequest + Authorize) ✓
├── Pruebas Automatizadas (18 Dimensiones) ✓
└── Documentación y Trazabilidad           ✓
```

---

## 4. FASE 3: DESPUÉS DE TERMINAR EL DESARROLLO (VERIFICACIÓN RIGUROSA)

> [!CAUTION]
> **PROHIBICIÓN ABSOLUTA DE DECIR "YA TERMINÉ" SIN COMPROBACIÓN**  
> Ningún caso de uso puede declararse terminado ni pasar a Pull Request sin superar los 5 filtros de control:

```text
DESARROLLO TERMINADO
        │
        ▼
1. Verificar código y ejecutar pruebas
        │
        ▼
2. Analizar calidad y cobertura
        │
        ▼
3. Analizar seguridad y vulnerabilidades
        │
        ▼
4. Verificar criterios de aceptación (100%)
        │
        ▼
¿Falta algún criterio? ──► SÍ ──► ❌ BLOQUEAR (NO SE PUEDE FINALIZAR)
        │
       NO (100% CUMPLIDO)
        │
        ▼
5. HABILITADO PARA CREAR PULL REQUEST
```

### Filtro 1: Ejecución y Resultado de Pruebas
Ejecuta la suite de pruebas del backend y frontend:
- `dotnet test CORLAD_SistemaIntegral.sln`
- `npm run test` (o `npm run test:coverage`)

```text
PRUEBAS DEL SISTEMA
--------------------------------------------------
Tests ejecutados: [Total, ej: 48]
Tests aprobados:  [Total, ej: 48]
Tests fallidos:   0

Resultado: ✓ APROBADO
```

### Filtro 2: Análisis de Calidad y Deuda Técnica
Revisa métricas de mantenibilidad y cobertura:
```text
CALIDAD DEL CÓDIGO
--------------------------------------------------
Cobertura de código:     [ej: 89%]  (Criterio mínimo: ≥ 80%)
Errores críticos:        0          (Criterio estricto: 0)
Código duplicado:        [ej: 2.1%] (Criterio máximo: ≤ 5%)
Complejidad ciclomática: Aceptable  (Promedio ≤ 10)

Resultado: ✓ APROBADO
```

### Filtro 3: Seguridad y Mitigación de Vulnerabilidades
Verificación de los vectores de ataque críticos:
```text
SEGURIDAD DEL SISTEMA
--------------------------------------------------
SQL Injection:           ✓ Protegido (SqlParameter fuertemente tipados)
XSS (Cross-Site):        ✓ Sanitizado en frontend y FormRequest
Autorización RBAC:       ✓ Implementada con Authorize(rol)
Autenticación JWT:       ✓ Bearer Tokens validados
Exposición de datos:     ✓ Respuestas filtradas vía DTOs

Vulnerabilidades críticas: 0

Resultado: ✓ APROBADO
```

### Filtro 4: Verificación Uno a Uno de Criterios de Aceptación
`/gitfin-bot` confronta cada casilla del Issue original contra la implementación real:
```text
CRITERIOS DE ACEPTACIÓN
--------------------------------------------------
[✓] Formulario accesible y componente base heredado
[✓] Validación de campos obligatorios
[✓] Validación de formato DNI / RUC / Email
[✓] Reglas de negocio institucionales cumplidas
[✓] Almacenamiento seguro de credenciales
[✓] Notificaciones visuales de confirmación
[✓] Registro auditado en base de datos

Resultado: 7/7 cumplidos (100%)
```

> [!WARNING]
> **REGLA DE BLOQUEO ANTE CRITERIOS INCOMPLETOS:**  
> Si se detecta aunque sea **un solo criterio no cumplido**, `/gitfin-bot` emite una alerta roja y cancela el pase a Pull Request:
> ```text
> ❌ NO SE PUEDE FINALIZAR EL CASO DE USO
> Criterio pendiente: "[Nombre del criterio no satisfecho]"
> Acción requerida: Corregir o implementar la funcionalidad faltante antes de solicitar el cierre.
> ```

---

## 5. FASE 4: CREACIÓN DEL PULL REQUEST (PR FORMAL)

Una vez aprobados los 4 filtros, `/gitfin-bot` genera el Pull Request conectando la rama de feature con la rama principal:

```text
feature/[codigo-cu]-[nombre] ──► Pull Request ──► 🔵 EN REVISIÓN
```

### Plantilla Oficial de Pull Request:
```markdown
# PR: [Código CU] - [Nombre Oficial del Caso de Uso]

## 📌 Resumen de Cambios
- **Módulo:** `[Código Módulo]`
- **Backend:** Entidades DTO, FormRequest con `Authorize()`, `AccesoDatos` parametrizado y endpoints REST en `[Entidad]Controller.vb`.
- **Frontend:** Vistas en React compuestas con `BaseForm`, `BaseInput` y `BaseDataTable`, animaciones GSAP y consumo de API con interceptores.
- **Base de Datos:** Mapeo verificado con `CORLADJunin2026_SQLServer.sql` (0 modificaciones destructivas).

## 🧪 Pruebas Automatizadas
- **Total ejecutadas:** `[ej: 48/48]` ✓ (100% aprobadas)
- **Cobertura alcanzada:** `[ej: 89%]` ✓ (Supera el 80% mínimo institucional)

## 🛡️ Seguridad
- **Vulnerabilidades críticas:** `0` ✓
- **SQL Injection:** 0 (Parámetros `SqlParameter` obligatorios)
- **Control de Acceso:** RBAC con `Authorize(rol)`

## ✅ Criterios de Aceptación
- **Cumplimiento:** `[ej: 7/7]` criterios verificados y aprobados (100% ✓).

## 🏅 Certificación Normativa
- **Calidad ISO/IEC 25010:** Aprobada (9/9 dimensiones conformes por `/iso-bot`).

Closes #[Número de Issue]
```

---

## 6. FASE 5: MERGE, CIERRE DE ISSUE Y ACTUALIZACIÓN EN GITHUB PROJECT

Tras la aprobación del Pull Request:

```text
PR APROBADO ──► MERGE ──► main / develop
     │
     ▼
Issue #[Número] ──► CLOSED
     │
     ▼
GitHub Project: Mover tarjeta de 🟡 EN PROGRESO ──► 🟢 HECHO
```

### Estado del Tablero del Proyecto:
```text
┌─────────────────┬─────────────────┬─────────────────┐
│   POR HACER     │   EN PROGRESO   │      HECHO      │
├─────────────────┼─────────────────┼─────────────────┤
│ [Siguiente CU]  │                 │ [Código CU]  ✓  │
│                 │                 │ [CU Anterior]✓  │
└─────────────────┴─────────────────┴─────────────────┘
```

---

## 7. REPORTE FINAL CONSOLIDADO DE CIERRE (SALIDA OFICIAL DE `/gitfin-bot`)

Al concluir el ciclo completo de vida del requerimiento, `/gitfin-bot` emite el **Informe Oficial de Cierre de Caso de Uso**:

```markdown
---

# 🏁 INFORME CONSOLIDADO DE CIERRE DE CASO DE USO: [Código CU]
**Sistema Integrado de Gestión Institucional – CORLAD Junín**

### 1. DATOS GENERALES DEL CASO DE USO
- **Código y Nombre:** `[Código CU]: [Nombre Caso de Uso]`
- **Módulo Institucional:** `[Código Módulo, ej: CLI / CAJ / SGD]`
- **Actor Principal:** `[Nombre del Actor]`
- **Rama de Trabajo:** `feature/[codigo-cu]-[nombre]` ──► Fusionada en `main`
- **Issue Asociado:** `#[Número Issue]` (Estado: `CLOSED`)
- **Pull Request:** `PR #[Número PR]` (Estado: `MERGED`)

---

### 2. TRAZABILIDAD DE COMMITS Y ARTEFACTOS
- [✓] **Backend:** `[MOD].Entidades`, `[MOD].AccesoDatos`, `[MOD].FlujoTrabajo`, `CORLAD.API`.
- [✓] **Frontend:** `features/[mod]/components/`, `features/[mod]/hooks/`, `features/[mod]/services/`.
- [✓] **Commits Registrados:**
  - `feat([Código CU]): ...`
  - `feat([Código CU]): ...`
  - `test([Código CU]): ...`

---

### 3. AUDITORÍA DE CALIDAD Y CERTIFICACIÓN NORMATIVA
- **Pruebas Automatizadas:** `[ej: 48/48]` Aprobadas (`100% PASS`).
- **Cobertura de Código:** `[ej: 89%]` (Meta institucional: ≥ 80%).
- **Seguridad OWASP:** 0 vulnerabilidades críticas, 0 SQL Injection, RBAC verificado.
- **Certificación ISO/IEC 25010:** 9/9 criterios conformes auditados por `/iso-bot`.
- **Criterios de Aceptación:** `[ej: 7/7]` Verificados y aprobados al 100%.

---

### 4. ESTADO FINAL EN GITHUB PROJECT
```text
[Código CU: Nombre Caso de Uso] ──► 🟢 ESTADO: HECHO (DONE)
```

> [!NOTE]
> ### 🏆 **CASO DE USO FINALIZADO CON ÉXITO Y FUSIONADO EN PRODUCCIÓN**  
> El caso de uso ha completado rigurosamente todas las etapas del ciclo de ingeniería de software (análisis arquitectónico, desarrollo backend N-Tier, frontend React, diseño y responsividad, pruebas integrales, auditoría ISO/IEC 25010 y gobernanza Git). Se encuentra disponible y operativo en la rama principal.
```
