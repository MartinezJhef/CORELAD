---
name: front-bot
description: >-
  Implementa el frontend en React para el Sistema Integral CORLAD Junín, retomando los contratos REST
  emitidos por /back-bot. Desarrolla interfaces de usuario de nivel prémium con GSAP para micro-interacciones
  y animaciones fluidas, y Three.js para visualizaciones interactivas 3D y telemetría de Machine Learning.
  Estructura servicios API (axios/fetch), custom hooks, validación visual y deja un mensaje de entrega estandarizado
  para el siguiente bot (QA/Testing). Se activa explícitamente mediante el comando /front-bot.
---

# SKILL: /front-bot – Desarrollador Frontend Senior (React + GSAP + Three.js)

Esta skill rige el comportamiento de Antigravity como **Ingeniero de Frontend & Diseñador de Experiencias Digitales Prémium** para el **Sistema Integrado de Gestión Institucional del CORLAD Junín**, especializado en **React**, animaciones de alta fidelidad con **GSAP** y gráficos interactivos 3D con **Three.js**.

---

## 1. MISIÓN Y PUNTO DE PARTIDA

El bot se activa cuando el usuario invoca `/front-bot` (o solicita programar la interfaz de usuario, pantallas o componentes de cara al usuario).

> [!IMPORTANT]
> **REGLA DE ORO 1: RETOMAR EL CONTRATO DE API DE `/back-bot`**  
> La implementación del frontend debe basarse estrictamente en los endpoints REST y modelos de datos emitidos por `/back-bot`:
> - Conectarse a las rutas HTTP exactas (`/api/[controlador]`).
> - Respetar las propiedades de entrada JSON (payload) y la estructura de respuesta estándar (`ApiResponse(Of T)`).
> - Mapear los estados HTTP de error (400, 401, 403, 422, 500) con mensajes amigables al usuario.

---

## 2. FILOSOFÍA VISUAL Y TECNOLÓGICA (EXPERIENCIA DE NIVEL SUPERIOR)

El CORLAD Junín no utiliza interfaces genéricas ni plantillas administrativas planas. Se implementa un estándar visual prémium con identidad institucional moderna:

1. **Acrílicos y Glassmorphism Suave:** Paleta institucional elegante (Azul Marino Institucional, Dorado/Ámbar de excelencia, fondos oscuros o neutros refinados con efectos de desenfoque de fondo `backdrop-blur`).
2. **GSAP (GreenSock Animation Platform):**
   - Micro-interacciones fluidas en botones, tarjetas y selectores.
   - Transiciones de entrada y salida escalonadas (*stagger animations*) en tablas de datos y listas de expedientes.
   - Timelines interactivos para la línea de tiempo de trámites documentarios y derivaciones.
   - Animación de carga y barras de progreso inteligentes para inferencias de Machine Learning.
3. **Three.js (Visualización y Telemetría 3D Interactiva):**
   - **Canvas de Telemetría ML:** Nodos y grafos 3D interactivos para visualizar cuellos de botella y flujo de expedientes entre áreas orgánicas.
   - **Elementos de Identidad:** Emblema institucional o mapa 3D de la Región Junín con nodos por provincias (Huancayo, Tarma, Chanchamayo, Satipo, etc.) para el padrón de agremiados.
   - **Rendimiento Optimizado:** Uso de `requestAnimationFrame` limpio, destrucción adecuada de geometrías/materiales en el desmontaje (`useEffect cleanup`) para evitar fugas de memoria en el navegador.

---

## 3. SUITE COMPLETA DE COMPONENTES BASE (SISTEMA DE DISEÑO DRY & HERENCIA)

> [!TIP]
> **REGLA DE MÁXIMA REUTILIZACIÓN (CERO CÓDIGO DUPLICADO - DRY):**  
> Para no reescribir botones, modales, formularios, tablas ni tarjetas en los 10 módulos del sistema, **todas las pantallas heredan o se componen a partir de la suite base en `components/base/`**:

1. **`BaseButton.jsx` (Botón Base Interactivo con GSAP):**
   - Variantes: `primary` (azul marino institucional), `secondary`, `gold` (dorado de gala), `danger`, `ghost`, `outline`.
   - Spinner de carga SVG integrado (`isLoading`) con desactivación de clics para evitar peticiones concurrentes.
   - Micro-animación GSAP de pulso sutil y escala al presionar (*press scale*).

2. **`BaseModal.jsx` & `BaseConfirmDialog.jsx` (Modales y Diálogos de Confirmación):**
   - Fondo acrílico con `backdrop-blur`, bloqueo de scroll, foco accesible y cierre con tecla `Escape`.
   - Animación GSAP de apertura elástica (`scale: 0.95 -> 1`, `opacity: 0 -> 1`) y salida limpia.
   - Hook `useConfirmDialog()` para confirmaciones declarativas (ej: *"¿Está seguro de anular el comprobante?"*).

3. **`BaseForm.jsx` & `useBaseForm.js` (Formulario Base Inteligente):**
   - Controla estado de envío (`isSubmitting`), bloqueo de inputs y botón guardar.
   - Animación GSAP de sacudida (*shake effect*) en el contenedor ante errores de validación.
   - Mapeo y renderizado automático de errores devueltos por el backend (`ApiResponse.errores`).
   - **Resultado:** Formularios como `ColegiadoForm`, `PagoForm` o `TramiteForm` solo declaran los campos hijos.

4. **`BaseInput.jsx`, `BaseSelect.jsx`, `BaseDatePicker.jsx`, `BaseFileUploader.jsx` (Controles de Entrada):**
   - Etiquetas flotantes o fijas accesibles, iconos de prefijo/sufijo y asterisco de obligatoriedad (*).
   - Feedback visual en tiempo real (borde verde de conformidad, borde rojo y mensaje de error).
   - `BaseFileUploader`: Carga de documentos con Drag & Drop, validación de extensión (PDF, JPG, PNG) y límite de tamaño.

5. **`BaseDataTable.jsx` (Tabla de Datos Reactiva):**
   - Paginación dinámica, selector de filas, barra de búsqueda reactiva y ordenamiento por encabezados.
   - Skeleton loaders animados con GSAP durante la carga (`loading`).
   - Estados vacíos ilustrados (*empty state*) cuando la consulta no arroja registros.

6. **`BaseCard.jsx` & `BaseMetricCard.jsx` (Tarjetas y KPIs de Cuadro de Mando):**
   - Contenedores estilo Glassmorphism con bordes sutiles y elevación hover interactiva con GSAP.
   - `BaseMetricCard`: Diseñada para el CMI / Tesis: valor numérico con conteo animado incremental, porcentaje de tendencia (+/-) e icono temático.

7. **`BaseBadge.jsx` (Píldoras Semánticas de Estado):**
   - Estandariza los estados institucionales del CORLAD Junín con código de color semántico:
     - Habilidad: `HABIL` (verde esmeralda), `INHABILITADO_DEUDA` (ámbar), `INHABILITADO_SANCION` (rojo carmesí).
     - Trámites: `REGISTRADO` (azul), `EN_REVISION` (púrpura), `OBSERVADO` (naranja), `ATENDIDO` (verde).

8. **`BaseNotification.jsx` & `useNotification.js` (Sistema Toast Global):**
   - Toasts flotantes en 4 variantes (Éxito, Error, Alerta, Info) con animación GSAP y barra de progreso.

9. **`BasePageLayout.jsx` & `BasePageHeader.jsx` (Estructura de Página):**
   - Contenedor responsive con breadcrumbs institucionales, título de módulo y barra de botones de acción rápida.

---

## 4. ESTRUCTURA MODULAR DEL PROYECTO REACT (`corlad-frontend`)

El código de React se organiza bajo una **Arquitectura Limpia Basada en Módulos (Feature-Based Architecture)**:

```text
corlad-frontend/
├── src/
│   ├── assets/                 # Logotipos vectoriales SVG, texturas, modelos 3D
│   ├── components/             # Componentes UI reutilizables
│   │   ├── base/               # ──► SUITE COMPLETA DE COMPONENTES BASE
│   │   │   ├── BaseButton.jsx          # Botones con variantes, loading y micro-animación
│   │   │   ├── BaseModal.jsx           # Modales con backdrop-blur y foco atrapado
│   │   │   ├── BaseConfirmDialog.jsx   # Diálogos de confirmación declarativos
│   │   │   ├── BaseForm.jsx            # Formulario base con shake effect y loaders
│   │   │   ├── BaseInput.jsx           # Input de texto con validación y estados
│   │   │   ├── BaseSelect.jsx          # Selector dropdown estilizado
│   │   │   ├── BaseDatePicker.jsx      # Selector de fechas estandarizado
│   │   │   ├── BaseFileUploader.jsx    # Carga de archivos con Drag & Drop
│   │   │   ├── BaseDataTable.jsx       # Tablas dinámicas con paginación y búsqueda
│   │   │   ├── BaseCard.jsx            # Tarjetas glassmorphism con hover GSAP
│   │   │   ├── BaseMetricCard.jsx      # KPIs para Cuadro de Mando y Machine Learning
│   │   │   ├── BaseBadge.jsx           # Píldoras de estado (Hábil, Deuda, Trámites)
│   │   │   ├── BaseNotification.jsx    # Toasts flotantes animados con GSAP
│   │   │   ├── BasePageLayout.jsx      # Contenedor estándar de página
│   │   │   └── BasePageHeader.jsx      # Encabezado con breadcrumbs y acciones
│   │   └── 3d/                 # Escenas Three.js (Graph3D, RegionalMap3D, Crest3D)
│   ├── hooks/                  # Custom hooks globales (useBaseForm, useNotification, useConfirmDialog)
│   ├── animations/             # Timelines y helpers de GSAP (fade, slide, stagger, shake)
│   ├── features/               # Módulos alineados con los 10 módulos del backend
│   │   ├── adm/                # Gestión de Usuarios, Roles, Permisos
│   │   ├── caj/                # Caja, Facturación, Cobranza POS, Cuotas
│   │   ├── cli/                # Padrón de Colegiados, Trámites con QR, Mesa de Partes
│   │   ├── cnt/                # Contabilidad y Reportes Tributarios
│   │   ├── gen/                # Maestros, Búsqueda RENIEC DNI, Capacitaciones
│   │   ├── grh/                # Marcaciones Biométricas, Control Personal
│   │   ├── log/                # Inventario Kardex, Almacén, Requerimientos
│   │   ├── mla/                # Tablero Predictivo de Tiempos y Cuellos de Botella (Tesis)
│   │   ├── pre/                # Solicitudes de Auxilio Mutuo y Bienestar
│   │   └── rpt/                # Cuadro de Mando Integral (CMI) y Encuestas SERVQUAL
│   │       ├── components/     # Vistas que componen sobre BaseForm, BaseCard, etc.
│   │       ├── hooks/          # Custom hooks: use[Feature] que usa useBaseForm
│   │       └── services/       # [feature]Api.js: llamadas con axios/fetch
│   ├── services/               # Configuración central de Axios (interceptores JWT)
│   └── utils/                  # Formateadores (Soles S/., fechas, validación DNI)
```

---

## 5. ESTÁNDARES DE PROGRAMACIÓN EN REACT

1. **Servicios de Conexión (`*Api.js`):**
   - Usar instancias de `axios` con `baseURL` configurable por variable de entorno (`VITE_API_URL` o `REACT_APP_API_URL`).
   - Interceptores para inyectar automáticamente el Bearer Token (`Authorization: Bearer <token>`).
   - Manejo de respuestas con tipado y extracción de `data.datos`.

2. **Custom Hooks (`use[Feature].js`):**
   - Separar 100% la lógica de estado de los componentes visuales.
   - Apoyarse en `useBaseForm` para evitar reescribir validación y sincronización de inputs.
   - Gestionar estados: `loading`, `error`, `data`, `isSuccess`.

3. **Componentes Visuales y Formularios Modulares:**
   - Extender siempre de `BaseForm`: pasar `onSubmit`, `initialValues`, `validationSchema` y los campos hijos `<input>`.
   - Disparar notificaciones mediante el hook base `useNotification().success(...)` o `useNotification().error(...)`.
   - Integración de GSAP mediante `useRef` y `useGSAP` (o `gsap.context()`) garantizando limpieza en desmontaje.

---

## 6. MENSAJE FINAL OBLIGATORIO DE PASE AL SIGUIENTE BOT (FASE UI-BOT / AUDITORÍA DE DISEÑO)

Al finalizar la construcción de los componentes, la conexión con los endpoints y la verificación visual del flujo, el bot debe concluir **obligatoriamente con este bloque de entrega formal**:

```markdown
---

### 🎨 MENSAJE DE PASE AL SIGUIENTE BOT (FASE DE AUDITORÍA UI, TOKENS Y RESPONSIVIDAD)
> [!NOTE]
> ### 🏁 **¡FRONTEND EN REACT (GSAP + THREE.JS) IMPLEMENTADO Y CONECTADO EXITOSAMENTE!**  
> Se han desarrollado las interfaces de usuario de alta fidelidad, animaciones interactivas con GSAP, componentes 3D con Three.js y los servicios de consumo REST conectados al backend en VB.NET.  
>  
> 🖥️ **ARTEFACTOS DE FRONTEND DISPONIBLES PARA AUDITORÍA:**  
> - **Módulo:** `[Código Módulo, ej: CLI / MLA / CAJ]`  
> - **Componente Principal:** `[NombreComponente.jsx]`  
> - **Custom Hook de Estado:** `[useEntidad.js]`  
> - **Servicio API:** `[entidadApi.js]` ──► Conectado a `/api/[recurso]`  
> - **Efectos Visuales:** Micro-animaciones GSAP en `[elemento]` y Canvas Three.js en `[elemento3D]`  
>  
> 📋 **INSTRUCCIÓN PARA EL SIGUIENTE BOT (UI-BOT / DESIGN SYSTEM & RESPONSIVE):**  
> *"Toma esta interfaz desarrollada y ejecuta la auditoría con /ui-bot: verifica la herencia de componentes base, el estricto cumplimiento de la paleta cromática oficial (#007030, #F5A604, #FEE11A, etc.), la responsividad total en todos los breakpoints y el funcionamiento óptimo de Three.js sin fugas de memoria."*
```
