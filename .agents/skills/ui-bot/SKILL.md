---
name: ui-bot
description: >-
  Audita, valida y asegura la estricta consistencia visual, responsividad y cumplimiento del Sistema de Diseño
  institucional para el frontend React del CORLAD Junín. Enforce la paleta cromática oficial (Verde UO #007030,
  Verde Bosque #004D30, Amarillo Zapallo #F5A604, Amarillo Eléctrico #FEE11A, etc.), herencia obligatoria de
  componentes base (components/base/), adaptación 100% responsive y correcta renderización de Three.js sin fugas
  de memoria. Se activa explícitamente mediante el comando /ui-bot.
---

# SKILL: /ui-bot – Auditor de Consistencia Visual, Design System & Responsividad

Esta skill rige el comportamiento de Antigravity como **Auditor de Calidad Visual (UI/UX QA) y Guardián del Sistema de Diseño** para el frontend en React del **Sistema Integrado de Gestión Institucional del CORLAD Junín**.

---

## 1. MISIÓN Y PUNTO DE PARTIDA

El bot se activa cuando el usuario invoca `/ui-bot` (o solicita validar la interfaz de usuario, verificar consistencia visual, responsividad o rendimiento 3D).

> [!IMPORTANT]
> **REGLA DE ORO 1: RETOMAR LA ENTREGA DE `/front-bot`**  
> `/ui-bot` toma como insumo directo los componentes, vistas y servicios desarrollados por `/front-bot` y los audita rigurosamente para asegurar que:
> 1. Todas las pantallas pertenezcan al **mismo ecosistema visual armónico** (cero estilos dispares o desordenados).
> 2. Hereden obligatoriamente de la suite en `components/base/`.
> 3. Apliquen estrictamente la **paleta cromática institucional oficial**.
> 4. Sean **100% responsivas** desde teléfonos móviles hasta monitores 4K.
> 5. Los lienzos interactivos de **Three.js** funcionen sin deformaciones, con adaptación dinámica al tamaño de pantalla y sin fugas de memoria.

---

## 2. PALETA CROMÁTICA INSTITUCIONAL OFICIAL (TOKENS DE DISEÑO)

> [!CAUTION]
> **PROHIBIDO EL USO DE COLORES GENÉRICOS O NO AUTORIZADOS**  
> No se permiten tonos aleatorios de verde o azul. Toda la aplicación debe utilizar los tokens cromáticos normativos del CORLAD Junín:

| Token / Código HEX | Nombre Institucional | Muestra | Uso Específico en la Web | Variable CSS / Token |
| :--- | :--- | :---: | :--- | :--- |
| **`#007030`** | **Verde UO** | 🟩 | Color primario de marca, cabeceras institucionales, botones primarios de acción y acentos principales. | `--color-verde-uo` |
| **`#004D30`** | **Verde Bosque** | 🌲 | Secciones destacadas, banners, fondos oscuros con tinte institucional y gradientes base. | `--color-verde-bosque` |
| **`#F5A604`** | **Amarillo Zapallo** | 🎃 | Botones de llamada a la acción (CTA), insignias de alerta, estados pendientes (`OBSERVADO`) y acentos cálidos. | `--color-amarillo-zapallo` |
| **`#FEE11A`** | **Amarillo Eléctrico** | 🟨 | Anillos de enfoque (*focus rings* accesibles), bordes interactivos activos, brillos de tarjetas y micro-detalles. | `--color-amarillo-electrico` |
| **`#000000`** | **Negro Puro** | ⬛ | Pies de página (*footer*), fondos contrastados y texto titular de alto impacto. | `--color-negro-puro` |
| **`#3D4546`** | **Gris Carbón** | 🌑 | Color principal para párrafos y textos de lectura prolongada (evita la fatiga visual del negro puro). | `--color-gris-carbon` |
| **`#FFFFFF`** | **Blanco Puro** | ⬜ | Fondo general, tarjetas de contenido, modales y textos sobre fondos oscuros. | `--color-blanco-puro` |

### Reglas de Aplicación Cromática:
- **Botón Primario:** Fondo `#007030` (Verde UO), texto `#FFFFFF`, hover con `#004D30` (Verde Bosque) y focus ring `#FEE11A` (Amarillo Eléctrico).
- **Botón de Acción Crítica / Alerta:** Fondo `#F5A604` (Amarillo Zapallo), texto `#000000`.
- **Textos de Lectura:** `#3D4546` (Gris Carbón) sobre fondo `#FFFFFF` para cumplir con ratio de contraste WCAG AAA.
- **Píldoras de Estado (Badges):**
  - Hábil: Fondo `#007030` con texto `#FFFFFF`.
  - Inhábil por Deuda: Fondo `#F5A604` con texto `#000000`.
  - Inhábil por Sanción / Rechazado: Fondo `#DC2626` con texto `#FFFFFF`.

---

## 3. AUDITORÍA DE COMPONENTES BASE (PROHIBICIÓN DE CÓDIGO REDUNDANTE)

`/ui-bot` inspecciona el código para certificar que **ninguna vista cree elementos HTML huérfanos o estilos ad-hoc**:

- [ ] **Formularios:** ¿Componen usando `BaseForm` y `useBaseForm` en lugar de etiquetas `<form>` artesanales?
- [ ] **Controles:** ¿Los campos de entrada utilizan `BaseInput`, `BaseSelect`, `BaseDatePicker` o `BaseFileUploader`?
- [ ] **Botones:** ¿Todo botón proviene de `BaseButton` (con loader SVG y variante semántica)?
- [ ] **Tablas:** ¿Las grillas de datos derivan de `BaseDataTable` (con paginación y skeletons)?
- [ ] **Tarjetas & KPIs:** ¿Los tableros ejecutivos y métricas de Machine Learning utilizan `BaseCard` y `BaseMetricCard`?
- [ ] **Modales & Notificaciones:** ¿Los diálogos y alertas consumen `BaseModal` y `BaseNotification`?
- [ ] **Layout:** ¿Las pantallas están envueltas en `BasePageLayout` con `BasePageHeader`?

---

## 4. RESPONSIVIDAD TOTAL (MOBILE-FIRST A PANTALLAS 4K)

El bot evalúa y asegura que las vistas se adapten con fluidez a cualquier resolución mediante CSS Grid y Flexbox responsivo:

1. **Móviles (`< 640px`):**
   - Menú de navegación colapsado en drawer lateral suave con animación GSAP.
   - Tablas de datos transformadas automáticamente en tarjetas apiladas (*card-stack layout*) para evitar scroll horizontal molesto.
   - Modales adaptados como paneles inferiores (*bottom-sheet*) de fácil alcance táctil.
2. **Tabletas (`640px - 1024px`):**
   - Grillas adaptadas a 2 columnas equilibradas.
   - Tablas con scroll horizontal suave e indicador visual de desplazamiento.
3. **Escritorio (`1024px - 1440px`):**
   - Barra lateral colapsable institucional y área de trabajo optimizada.
4. **Pantallas Grandes y 4K (`> 1440px`):**
   - Contenedor con ancho máximo centrado (`max-w-7xl` o `max-w-[1600px]`) evitando que los elementos se estiren de forma desproporcionada.

---

## 5. CONTROL Y OPTIMIZACIÓN DE THREE.JS

`/ui-bot` realiza una auditoría técnica especializada sobre cada escena y canvas 3D:

1. **Redimensionamiento Reactivo (*Resize Handler*):**
   - El canvas debe escuchar el resize del contenedor o ventana:
     ```javascript
     const handleResize = () => {
       if (!containerRef.current || !rendererRef.current || !cameraRef.current) return;
       const width = containerRef.current.clientWidth;
       const height = containerRef.current.clientHeight;
       cameraRef.current.aspect = width / height;
       cameraRef.current.updateProjectionMatrix();
       rendererRef.current.setSize(width, height);
     };
     ```
2. **Limitación de Densidad de Píxeles (Evitar Lag en Pantallas Retina):**
   - `renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));`
3. **Liberación Estricta de Recursos en Desmontaje (Clean-up):**
   - En el `useEffect`, asegurar la cancelación del ciclo de animación (`cancelAnimationFrame`) y el desecho de geometrías, materiales y texturas (`geometry.dispose()`, `material.dispose()`).
4. **No Invasión de la Usabilidad:**
   - Si el canvas 3D es de fondo o telemetría, debe tener `pointer-events-none` o estar contenido dentro de su tarjeta interactiva para no bloquear los clics en botones o formularios.

---

## 6. INFORME DE SALIDA DE `/ui-bot`

Al ejecutarse, `/ui-bot` genera un informe de auditoría y optimización estructurado en:
1. **Verificación de Paleta Cromática:** Cumplimiento de tokens (#007030, #F5A604, etc.).
2. **Auditoría de Herencia Base:** Confirmación de uso de `components/base/`.
3. **Certificación de Responsividad:** Comportamiento validado en móvil, tablet y desktop.
4. **Diagnóstico Three.js & GSAP:** Rendimiento FPS, redimensionamiento dinámico y limpieza de memoria.
5. **Cierre de Entrega para Testing / QA:**

```markdown
---

### 🧪 MENSAJE DE PASE AL SIGUIENTE BOT (FASE DE PRUEBAS FUNCIONALES Y E2E)
> [!NOTE]
> ### 🏁 **¡DISEÑO AUDITADO, 100% RESPONSIVE Y ALINEADO AL DESIGN SYSTEM!**  
> Se ha certificado que la interfaz cumple rigurosamente con la paleta cromática oficial del CORLAD Junín, hereda de los componentes base sin código redundante, responde a todas las resoluciones y ejecuta Three.js con óptimo rendimiento.  
>  
> 📋 **INSTRUCCIÓN PARA EL SIGUIENTE BOT (QA-BOT / TESTER):**  
> *"Toma esta interfaz visualmente estandarizada y responsive para ejecutar las pruebas funcionales de extremo a extremo (E2E), validación de criterios BDD (Given-When-Then), pruebas de carga de la API y verificación de flujos institucionales completos."*
```
