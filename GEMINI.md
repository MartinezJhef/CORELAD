# Reglas de Proyecto: Sistema Integrado de Gestión CORLAD Junín

Este espacio de trabajo contiene la solución para el Sistema Integrado de Gestión Institucional del Colegio Regional de Licenciados en Administración de Junín (CORLAD Junín).

---

## 0. Comando Especial: `/gitini-bot` (Apertura y Preparación del Caso de Uso en Git/GitHub)
Cuando el usuario escriba `/gitini-bot` (o mencione inicializar un caso de uso, crear ramas Git, abrir Issues o configurar GitHub Projects antes de programar):
1. **Activar de inmediato la skill `gitini-bot`** ubicada en `.agents/skills/gitini-bot/SKILL.md`.
2. **Consultar obligatoriamente las fuentes normativas:**
   - `DOCUMENTOS INTERNOS CORLAD/3.CASOS_DE_USO_SISTEMA_INTEGRAL_CORLAD.md`
   - `DOCUMENTOS INTERNOS CORLAD/2.HISTORIAS_DE_USUARIO_SISTEMA_INTEGRAL_CORLAD.md`
   - `DOCUMENTOS INTERNOS CORLAD/1.REQUERIMIENTOS_FUNCIONALES_SISTEMA_INTEGRAL_CORLAD.md`
3. **Extraer el Código Oficial y Nombre del Caso de Uso** (`CU-COL-01`, `CU-HAB-02`, etc.), actor institucional, objetivo y precondiciones.
4. **Generar Criterios de Aceptación** en formato checklist (`[ ]`).
5. **Crear el GitHub Issue** con la plantilla técnica estructurada por capas (Base de datos, Backend N-Tier, Frontend React y Pruebas).
6. **Asignar al GitHub Project** en la columna `📋 POR HACER`.
7. **Crear y activar la rama Git de trabajo:** `git checkout -b feature/[codigo-cu]-[nombre-kebab-case]` y actualizar el estado a `🟡 EN PROGRESO`.
8. **Cerrar con el mensaje estandarizado de pase al siguiente bot (Estructuración Arquitectónica: `/arbol-bot`).**

---

## 1. Comando Especial: `/arbol-bot`
Cuando el usuario escriba `/arbol-bot` (o mencione estructuración arquitectónica de un caso de uso, proceso o requerimiento):
1. **Activar de inmediato la skill `arbol-bot`** ubicada en `.agents/skills/arbol-bot/SKILL.md`.
2. **Cruzar obligatoriamente los 5 documentos fuente:**
   - `DOCUMENTOS INTERNOS CORLAD/0.ANALISIS_PROCESOS_CORLAD_BIZAGI_SOFTWARE.md`
   - `DOCUMENTOS INTERNOS CORLAD/1.REQUERIMIENTOS_FUNCIONALES_SISTEMA_INTEGRAL_CORLAD.md`
   - `DOCUMENTOS INTERNOS CORLAD/2.HISTORIAS_DE_USUARIO_SISTEMA_INTEGRAL_CORLAD.md`
   - `DOCUMENTOS INTERNOS CORLAD/3.CASOS_DE_USO_SISTEMA_INTEGRAL_CORLAD.md`
   - `DOCUMENTOS INTERNOS CORLAD/CORLADJunin2026_SQLServer.sql`
3. **PROHIBICIÓN ABSOLUTA DE PROGRAMAR CÓDIGO:**
   - No escribir algoritmos de negocio en VB.NET.
   - No escribir consultas SQL interactivas.
   - No programar componentes o pantallas en React.
   - **SOLO ESTRUCTURAR:** Mapear carpetas, definir entidades DTO, interfaces con firmas de métodos, endpoints REST y relaciones con la base de datos según la plantilla oficial de `/arbol-bot`.
4. **MENSAJE FINAL DE ENTREGA:**
   - Al terminar, arrojar obligatoriamente el mensaje de cierre estandarizado indicando que el análisis arquitectónico está listo para que el siguiente bot lo tome como insumo base para la fase de programación.

---

## 2. Arquitectura Oficial: Solución N-Tier en Visual Basic .NET
Toda propuesta debe mapear estrictamente a la solución `CORLAD_SistemaIntegral.sln` (44 proyectos en net8.0):
- **10 Módulos Canónicos:** `ADM`, `CAJ`, `CLI`, `CNT`, `GEN`, `GRH`, `LOG`, `MLA`, `PRE`, `RPT`.
- **Capas:**
  - `CapaAccesoDatos` (`ComponenteLogicoAccesoDatos/[MOD]/[MOD].AccesoDatos`, `Helper/Helper.AccesoDatos`)
  - `CapaInfraestructuraComun` (`AdminitracionOperacional/GEN.Infraestructura`)
  - `CapaNegocios` (`EntidadesEmpresariales`, `InterfacesServicios`, `FlujoTrabajoEmpresariales`)
  - `CapaPresentacion` (`CORLAD.API` - Web API REST para React, `CORLAD.Web`)
  - `Instaladores` (`BaseDatos/CORLADJunin2026_SQLServer.sql`)
- **Frontend:** React (SPA independiente) que consume los servicios de `CORLAD.API`.

---

## 3. Comando Especial: `/back-bot`
Cuando el usuario escriba `/back-bot` (o mencione programación/implementación de backend en VB.NET):
1. **Activar de inmediato la skill `back-bot`** ubicada en `.agents/skills/back-bot/SKILL.md`.
2. **Retomar rigurosamente el análisis emitido por `/arbol-bot`** como insumo base obligatorio.
3. **Consultar `.antigravity/context/Script.sql`** para garantizar tipos de datos exactos, llaves foráneas y checks.
4. **Aplicar Clean Code, nombres descriptivos, principios DRY y KISS.**
5. **Implementar FormRequests con métodos `Authorize()` reales, reglas de validación y sanitización contra inyecciones.**
6. **Cerrar con el mensaje estandarizado de pase al siguiente bot (Frontend / React).**

---

## 4. Comando Especial: `/front-bot`
Cuando el usuario escriba `/front-bot` (o mencione desarrollo frontend en React):
1. **Activar de inmediato la skill `front-bot`** ubicada en `.agents/skills/front-bot/SKILL.md`.
2. **Retomar rigurosamente el contrato de API REST emitido por `/back-bot`** (URLs, métodos, payloads JSON y respuestas estándar).
3. **Implementar arquitectura limpia basada en módulos (Feature-Based) en React:**
   - `features/[modulo]/components/`, `hooks/`, `services/`.
4. **Estándar visual de nivel prémium:**
   - **GSAP:** Micro-interacciones fluidas, transiciones escalonadas (*stagger*), timelines de expedientes.
   - **Three.js:** Telemetría interactiva 3D para grafos de cuellos de botella (ML) y mapa/emblema 3D.
5. **Cerrar con el mensaje estandarizado de pase al siguiente bot (Auditor UI / Design System: `/ui-bot`).**

---

## 5. Comando Especial: `/ui-bot`
Cuando el usuario escriba `/ui-bot` (o mencione auditoría de interfaz, consistencia visual, responsividad o rendimiento de Three.js):
1. **Activar de inmediato la skill `ui-bot`** ubicada en `.agents/skills/ui-bot/SKILL.md`.
2. **Retomar rigurosamente los componentes y vistas emitidos por `/front-bot`** como insumo base.
3. **Garantizar la herencia obligatoria de componentes base:** Todas las vistas deben reutilizar exclusivamente la suite en `components/base/` (`BaseButton`, `BaseModal`, `BaseForm`, `BaseInput`, `BaseDataTable`, `BaseCard`, `BasePageLayout`, etc.) eliminando estilos ad-hoc y código duplicado.
4. **Hacer cumplir estrictamente la Paleta Cromática Institucional Oficial (Design Tokens):**
   - Verde UO (`#007030`), Verde Bosque (`#004D30`), Amarillo Zapallo (`#F5A604`), Amarillo Eléctrico (`#FEE11A`), Negro Puro (`#000000`), Gris Carbón (`#3D4546`), Blanco Puro (`#FFFFFF`). Prohibido el uso de colores genéricos o no autorizados.
5. **Garantizar Responsividad Total (Mobile-First a Pantallas 4K):** Transformación móvil de tablas a tarjetas apiladas, menús responsivos con drawer animado, modales táctiles adaptativos y límite centrado en resoluciones ultra anchas.
6. **Auditar y Optimizar Three.js:** Verificación de resize dinámico (`handleResize`), limitación de densidad de píxeles (`setPixelRatio(min(devicePixelRatio, 2))`), limpieza estricta de geometrías y ciclo de render en desmontaje (`dispose`, `cancelAnimationFrame`), y prevención de bloqueo de clics (`pointer-events-none`).
7. **Cerrar con el mensaje estandarizado de pase al siguiente bot (Testing / QA - BDD, E2E y Carga).**

---

## 6. Comando Especial: `/qa-bot`
Cuando el usuario escriba `/qa-bot` (o mencione aseguramiento de calidad, pruebas unitarias, BDD, E2E, carga o certificación técnica):
1. **Activar de inmediato la skill `qa-bot`** ubicada en `.agents/skills/qa-bot/SKILL.md`.
2. **Retomar rigurosamente la entrega emitida por `/ui-bot`** (interfaz estandarizada y responsive) y cruzar transversalmente lo construido en:
   - **Backend (`/back-bot`):** VB.NET N-Tier, SQL Server 2026, DTOs, FormRequests con `Authorize()`, `AccesoDatos` parametrizado y endpoints REST `ApiResponse(Of T)`.
   - **Frontend (`/front-bot`):** React, arquitectura por features, hooks, llamadas Axios, micro-animaciones GSAP y canvas Three.js.
   - **Diseño (`/ui-bot`):** Suite `components/base/`, tokens institucionales oficiales (#007030, #F5A604, etc.), responsividad adaptativa y Three.js sin fugas de memoria.
3. **Ejecutar y certificar la Matriz Integral de las 18 Dimensiones de Pruebas:**
   - 1. Pruebas unitarias (cálculos y métodos aislados en .NET y React).
   - 2. Pruebas de integración (`CORLAD.API` + `FlujoTrabajo` + `AccesoDatos` + SQL Server).
   - 3. Pruebas funcionales (cumplimiento de casos de uso institucionales).
   - 4. Pruebas de aceptación BDD (escenarios *Given-When-Then* de HUs y Casos de Uso).
   - 5. Pruebas de regresión (garantizar que cambios no rompan módulos cruzados).
   - 6. Pruebas de errores / excepciones (resiliencia ante 400, 404, 409, 500 controlado).
   - 7. Pruebas de validación (DNI 8 dígitos, RUC 11 dígitos, montos positivos, campos requeridos).
   - 8. Pruebas de seguridad (0 SQLi con parámetros tipados, XSS sanitizado, RBAC con `Authorize()` y JWT).
   - 9. Pruebas de rendimiento (P95 de API < 200 ms, React a 60 FPS estables).
   - 10. Pruebas de carga (simulación de 100 a 500 usuarios concurrentes con k6/JMeter).
   - 11. Pruebas de estrés (evaluación de punto de quiebre y pool de conexiones SQL Server).
   - 12. Pruebas de API (contratos REST, códigos de estado y esquema `ApiResponse(Of T)`).
   - 13. Pruebas de base de datos (restricciones `FK_`, `CK_`, consistencia ACID y rollback).
   - 14. Pruebas de interfaz (UI con React Testing Library: estados de botones, focus trapping en modales).
   - 15. Pruebas E2E (flujos completos de inicio a fin con Playwright: login -> trámite -> caja -> constancia QR).
   - 16. Análisis estático (Clean Code, SOLID, DRY, KISS, cero código muerto).
   - 17. Pruebas de cobertura (meta obligatoria de cobertura >= 80% en lógica de negocio).
   - 18. Pruebas de compatibilidad (Chrome, Edge, Firefox, Safari, pantallas móviles y monitores 4K).
4. **Cerrar obligatoriamente con el mensaje estandarizado de pase al siguiente bot (Auditoría de Calidad ISO/IEC 25010: `/iso-bot`).**

---

## 7. Comando Especial: `/iso-bot`
Cuando el usuario escriba `/iso-bot` (o mencione auditoría de calidad ISO, métricas de calidad de software o evaluación ISO/IEC 25010):
1. **Activar de inmediato la skill `iso-bot`** ubicada en `.agents/skills/iso-bot/SKILL.md`.
2. **Retomar rigurosamente los resultados emitidos por `/qa-bot`** (las 18 dimensiones de pruebas, métricas de rendimiento, cobertura, seguridad y resiliencia).
3. **Evaluar los Criterios de Calidad del Software bajo la norma ISO/IEC 25010 (SQuaRE):**
   - **Adecuación funcional:** Que haga lo que indican los requisitos (Pruebas funcionales).
   - **Eficiencia de desempeño:** Velocidad y uso de recursos (Pruebas de carga/estrés/latencia).
   - **Compatibilidad:** Que funcione con otros sistemas (API, navegador, base de datos).
   - **Usabilidad:** Que sea fácil de utilizar (Evaluación SUS / satisfacción de usuarios, WCAG).
   - **Fiabilidad:** Que funcione correctamente y se recupere de errores (Pruebas de fallos).
   - **Seguridad:** Protección de datos y accesos (SQL Injection, XSS, autenticación, RBAC).
   - **Mantenibilidad:** Que sea fácil modificar y mantener (Análisis estático, complejidad ciclomática).
   - **Portabilidad:** Que pueda ejecutarse en diferentes entornos (Navegadores, contenedores, servidores).
   - **Cobertura:** Pruebas automatizadas (Cobertura >= 80%).
   - **Estrés:** Resistencia de concurrencia extrema (>= 1,000 usuarios concurrentes).
4. **Emitir obligatoriamente el reporte en la estructura de 7 columnas:**
   `| N.º | Criterio de calidad | Prueba realizada | Indicador | Resultado obtenido | Criterio mínimo | Estado |`
5. **Cerrar obligatoriamente con el mensaje estandarizado de pase al siguiente bot (Trazabilidad Git, PR & Cierre de Caso de Uso: `/gitfin-bot`).**

---

## 8. Comando Especial: `/gitfin-bot`
Cuando el usuario escriba `/gitfin-bot` (o mencione trazabilidad Git, control de commits, creación de Pull Request, cierre de Issues en GitHub Projects o consolidación final de un caso de uso):
1. **Activar de inmediato la skill `gitfin-bot`** ubicada en `.agents/skills/gitfin-bot/SKILL.md`.
2. **FASE PRE-DESARROLLO (Apertura y Preparación):**
   - Extraer código, nombre, actor, objetivo y precondición formal del Caso de Uso desde `DOCUMENTOS INTERNOS CORLAD/3.CASOS_DE_USO_SISTEMA_INTEGRAL_CORLAD.md`.
   - Crear el GitHub Issue oficial con criterios de aceptación (`[ ]`) y checklist de tareas técnicas por capas.
   - Asignar al GitHub Project en columna `📋 POR HACER`.
   - Crear rama Git: `git checkout -b feature/[codigo-cu]-[nombre-kebab-case]` y mover a `🟡 EN PROGRESO`.
3. **FASE DURANTE EL DESARROLLO (Trazabilidad de Commits):**
   - Exigir obligatoriamente Conventional Commits referenciando el código del caso de uso: `feat(CU-XXX-NN): ...`, `test(CU-XXX-NN): ...`.
   - Monitorear el árbol de trazabilidad (Código ✓, Commit ✓, Validaciones ✓, Tests ✓, Documentación ✓).
4. **FASE POST-DESARROLLO (Verificación Rigurosa):**
   - Prohibido finalizar sin comprobar:
     - 1. Ejecutar pruebas (`dotnet test` / `npm test`) con 0 fallos.
     - 2. Análisis de calidad (cobertura ≥ 80%, 0 errores críticos, duplicación ≤ 5%).
     - 3. Análisis de seguridad (0 vulnerabilidades críticas, 0 SQL Injection, RBAC validado).
     - 4. Verificación del 100% de criterios de aceptación del Issue. Si falta 1: **BLOQUEAR FINALIZACIÓN**.
5. **FASE DE CIERRE (Pull Request, Merge & GitHub Project):**
   - Crear Pull Request formal vinculando `Closes #[NumeroIssue]` y pasar a `🔵 EN REVISIÓN`.
   - Tras aprobación, ejecutar Merge a rama principal (`main`/`develop`).
   - Cerrar el Issue automáticamente (`CLOSED`) y actualizar la tarjeta del GitHub Project a `🟢 HECHO`.
6. **Emitir el Informe Consolidado Final de Cierre del Caso de Uso.**



