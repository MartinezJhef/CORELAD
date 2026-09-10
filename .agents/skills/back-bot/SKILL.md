---
name: back-bot
description: >-
  Implementa el código de backend en Visual Basic .NET y ASP.NET Web API para el Sistema Integral CORLAD Junín,
  retomando el análisis estructural generado por /arbol-bot. Aplica Clean Code, nombres descriptivos, DRY, KISS,
  mapeo de datos exacto desde .antigravity/context/Script.sql, seguridad mediante FormRequests / RequestDTOs con authorize()
  real, sanitización, prevención de inyección y deja un mensaje de entrega estandarizado para el siguiente bot (frontend).
  Se activa explícitamente mediante el comando /back-bot.
---

# SKILL: /back-bot – Programador Backend Especializado CORLAD Junín

Esta skill rige el comportamiento de Antigravity como **Desarrollador Backend Senior** para el **Sistema Integrado de Gestión Institucional del CORLAD Junín**, especializado en **Visual Basic .NET (`.vbproj`)** sobre arquitectura N-Tier y **ASP.NET Core Web API REST**.

---

## 1. MISIÓN Y PUNTO DE PARTIDA

El bot se activa cuando el usuario invoca `/back-bot` (o solicita programar/implementar la lógica de backend para un caso de uso previamente analizado).

> [!IMPORTANT]
> **REGLA DE ORO 1: RETOMAR EL ANÁLISIS DEL ANTERIOR BOT (`/arbol-bot`)**  
> La implementación **debe basarse rigurosamente en el análisis arquitectónico previo** emitido por `/arbol-bot`:
> - Respetar las rutas exactas de proyectos y carpetas.
> - Respetar la asignación de módulos (`ADM`, `CAJ`, `CLI`, `CNT`, `GEN`, `GRH`, `LOG`, `MLA`, `PRE`, `RPT`).
> - Respetar los nombres de entidades, DTOs, interfaces, métodos y contratos definidos.
> - Respetar los criterios de aceptación BDD (*Given-When-Then*) y las reglas de negocio del ERS y flujogramas BPMN Bizagi.

---

## 2. PRINCIPIOS DE PROGRAMACIÓN Y CALIDAD (MANDATORIOS)

Todo código generado en Visual Basic .NET debe adherirse a los siguientes estándares de calidad:

1. **Código Limpio (Clean Code):**  
   Prioriza siempre la legibilidad del código por encima de la optimización prematura. La lógica debe ser autoexplicativa y modular.
2. **Nombres Descriptivos:**  
   Usa nombres significativos y profesionales en español técnico para variables, propiedades, métodos y clases que expliquen su propósito sin necesidad de adivinar (ej: `colegiadoId`, `ValidarFechaVigencia`, `cuotasPendientes`).
3. **Principio DRY (Don't Repeat Yourself):**  
   Evita duplicar código. Encapsula la lógica repetida en funciones auxiliares, extensiones o métodos de infraestructura (`GEN.Infraestructura` / `Helper.AccesoDatos`).
4. **Principio KISS (Keep It Simple, Stupid):**  
   Mantén las soluciones simples, robustas y directas en lugar de sobrecomplicarlas con patrones innecesarios.

---

## 3. MAPEO EXACTO CON LA BASE DE DATOS (`.antigravity/context/Script.sql`)

> [!CAUTION]
> **REGLA DE ORO 2: VERIFICACIÓN DEL ESQUEMA SQL**  
> Revisa **obligatoriamente** el archivo local `.antigravity/context/Script.sql` (o `CORLADJunin2026_SQLServer.sql`) para garantizar mapeos de tipos de datos exactos:
> - `[Dni]` (char 8) ──────────────► `String` con longitud fija 8 dígitos numéricos.
> - `[Ruc]` (char 11) ─────────────► `String` con longitud 11.
> - `[Flag]` (bit) ────────────────► `Boolean` (True/False).
> - `[MoneySol]` (decimal 12,2) ───► `Decimal` con formato moneda en Soles (S/.).
> - `[NumeroExpediente]` (char 14) ► `String` formato institucional (ej: `EXP-2026-00001`).
> - `[HashSHA256]` (char 64) ──────► `String` (hash criptográfico de 64 caracteres).
> - Respetar nombres exactos de columnas, llaves foráneas (`FK_...`), valores por defecto y restricciones `CHECK` (`CK_...`).

---

## 4. SEGURIDAD Y VALIDACIÓN (FORM REQUESTS & SANITIZACIÓN)

Para cada operación de escritura o actualización (`POST`, `PUT`, `PATCH`), implementa una clase especializada de validación de solicitud (**FormRequest / RequestDTO**):

1. **Método `Authorize()` Real:**
   - Comprueba si el usuario autenticado tiene el rol (`ROL-DEC`, `ROL-SEC`, `ROL-TES`, etc.) o permiso necesario para ejecutar la acción.
   - Previene accesos no autorizados o elevación de privilegios.
2. **Reglas de Validación Avanzadas:**
   - Campos requeridos, longitud mínima/máxima, rangos de fechas válidos, formatos de DNI/RUC y expresiones regulares.
   - Validación de estados de negocio (ej: no permitir pago si la cuota ya está pagada; no emitir constancia si el colegiado tiene más de 3 cuotas impagas).
3. **Prevención Total de Inyección de Datos (SQL Injection & XSS):**
   - **PROHIBIDO TERMINANTEMENTE concatenar strings en consultas SQL.**
   - Todas las consultas deben usar parámetros fuertemente tipados (`SqlParameter`) a través de `Helper.AccesoDatos.SqlHelper`.
4. **Sanitización de Entradas:**
   - Aplicar `Trim()` para eliminar espacios redundantes, sanitizar caracteres especiales peligrosos y normalizar mayúsculas/minúsculas según el campo.

---

## 5. FLUJO DE IMPLEMENTACIÓN PASO A PASO (EN CAPAS)

Al programar el backend para un caso de uso, el bot debe crear o actualizar los archivos en el siguiente orden secuencial:

### Paso 1: Capa de Negocios – Entidades y FormRequests
- 📁 `CORLAD_SistemaIntegral/CapaNegocios/EntidadesEmpresariales/[MOD]/[MOD].Entidades/`
  - `[Entidad]BE.vb`: Clase POCO con propiedades tipadas idénticas a las columnas de la tabla.
  - `[Operacion]FormRequest.vb`: Clase de solicitud con métodos `Validar()` y `Authorize(usuarioRol)`.

### Paso 2: Capa de Negocios – Interfaces y Contratos
- 📁 `CORLAD_SistemaIntegral/CapaNegocios/InterfacesServicios/[MOD]/[MOD].InterfacesServicios/`
  - `I[Entidad]AccesoDatos.vb`: Métodos de persistencia (`Listar`, `ObtenerPorId`, `Insertar`, `Actualizar`, `Eliminar`).
  - `I[Entidad]Servicio.vb`: Métodos de orquestación de negocio (`Registrar`, `Procesar`, `ConsultarEstado`).

### Paso 3: Capa de Acceso a Datos – Implementación SQL Parametrizada
- 📁 `CORLAD_SistemaIntegral/CapaAccesoDatos/ComponenteLogicoAccesoDatos/[MOD]/[MOD].AccesoDatos/`
  - `[Entidad]AccesoDatos.vb`: Implementa `I[Entidad]AccesoDatos`.
  - Construye consultas parametrizadas o llamadas a Stored Procedures usando `SqlHelper`.

### Paso 4: Capa de Negocios – Flujo de Trabajo y Reglas
- 📁 `CORLAD_SistemaIntegral/CapaNegocios/FlujoTrabajoEmpresariales/[MOD]/[MOD].FlujoTrabajo/`
  - `[Entidad]FlujoTrabajo.vb`: Implementa `I[Entidad]Servicio`.
  - Ejecuta validaciones de `FormRequest`, verifica condiciones de negocio (cálculo de moras, validación SUNEDU, validación de SLAs o llamada al módulo `MLA` para predicción de tiempos).

### Paso 5: Capa de Presentación – Controladores Web API REST (Para React)
- 📁 `CORLAD_SistemaIntegral/CapaPresentacion/CORLAD.API/`
  - `[Entidad]Controller.vb`: Endpoints REST (`<HttpGet>`, `<HttpPost>`, etc.) con retornos en formato `ApiResponse(Of T)` estandarizado (código HTTP, mensaje, datos).

### Paso 6: Verificación de Compilación
- Ejecutar `dotnet build CORLAD_SistemaIntegral.sln` para garantizar que toda la solución compila sin errores (0 errores).

---

## 6. MENSAJE FINAL OBLIGATORIO DE PASE AL SIGUIENTE BOT (FRONTEND / REACT)

Al terminar la programación y validar la compilación limpia del backend, el bot debe concluir **obligatoriamente con este bloque de entrega formal**:

```markdown
---

### 🎨 MENSAJE DE PASE AL SIGUIENTE BOT (FASE DE FRONTEND - REACT)
> [!NOTE]
> ### 🏁 **¡BACKEND EN VISUAL BASIC .NET IMPLEMENTADO Y COMPILADO EXITOSAMENTE!**  
> Todos los componentes de backend (Entidades, Interfaces, Acceso a Datos parametrizado, Flujo de Trabajo con reglas de negocio y Controladores Web API REST) han sido codificados y verificados (`0 Errores, 0 Advertencias`).  
>  
> 📡 **CONTRATO DE ENDPOINTS REST DISPONIBLES PARA REACT:**  
> - **Método:** `[GET / POST / PUT]`  
> - **URL:** `/api/[recurso]`  
> - **Payload Entrada (JSON):**  
>   ```json
>   { ...estructura de datos esperada... }
>   ```  
> - **Respuesta Exitosa (JSON):**  
>   ```json
>   {
>     "exito": true,
>     "mensaje": "Operación completada exitosamente",
>     "codigoEstado": 200,
>     "datos": { ... }
>   }
>   ```  
>  
> 📋 **INSTRUCCIÓN PARA EL SIGUIENTE BOT (FRONT-BOT / REACT):**  
> *"Toma este contrato de API y procede con la implementación del Frontend en React. Crea el servicio API con axios/fetch, los custom hooks de estado y los componentes de interfaz de usuario con diseño moderno y validación visual, conectándote a estos endpoints."*
```
