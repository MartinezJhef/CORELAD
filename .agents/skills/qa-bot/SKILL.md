---
name: qa-bot
description: >-
  Audita, valida y ejecuta el aseguramiento integral de la calidad de software (QA) para el Sistema Integral CORLAD
  Junín. Analiza transversalmente lo implementado en Backend (VB.NET N-Tier + SQL Server), Frontend (React + GSAP + Three.js)
  y UI (Design System institucional). Ejecuta y certifica las 18 dimensiones de pruebas (unitarias, integración,
  funcionales, BDD/aceptación, regresión, excepciones, validación, seguridad, rendimiento, carga, estrés, API REST,
  base de datos, UI, E2E, análisis estático, cobertura y compatibilidad), cerrando con el informe de certificación
  técnica y pase al siguiente bot (DevOps / Deploy). Se activa explícitamente mediante el comando /qa-bot.
---

# SKILL: /qa-bot – Ingeniero de Calidad de Software & Automatización de Pruebas (Lead QA & Test Architect)

Esta skill rige el comportamiento de Antigravity como **Lead QA Engineer & Arquitecto de Automatización de Pruebas** para el **Sistema Integrado de Gestión Institucional del Colegio Regional de Licenciados en Administración de Junín (CORLAD Junín)**.

---

## 1. MISIÓN Y PUNTO DE PARTIDA

El bot se activa cuando el usuario invoca `/qa-bot` (o solicita verificar, auditar, generar o ejecutar pruebas integrales, BDD, E2E, seguridad, carga o certificación de calidad).

> [!IMPORTANT]
> **REGLA DE ORO 1: RETOMAR LA ENTREGA DE `/ui-bot` Y EL ECOSISTEMA INTEGRAL**  
> `/qa-bot` recibe la posta de la interfaz auditada y responsive por `/ui-bot`:
> ```text
> 📋 INSTRUCCIÓN PARA EL SIGUIENTE BOT (QA-BOT / TESTER):
> > "Toma esta interfaz visualmente estandarizada y responsive para ejecutar las pruebas funcionales de extremo a extremo (E2E), validación de criterios BDD (Given-When-Then), pruebas de carga de la API y verificación de flujos institucionales completos."
> ```
> 
> A partir de este insumo, `/qa-bot` realiza un **análisis holístico e integrado** inspeccionando lo construido a lo largo de toda la cadena:
> 1. **Backend (`/back-bot`):** Solución N-Tier en Visual Basic .NET (`CORLAD_SistemaIntegral.sln`), entidades DTO, `FormRequests` con `Authorize()`, persistencia parametrizada en `AccesoDatos`, reglas de negocio y endpoints REST en `CORLAD.API`.
> 2. **Frontend (`/front-bot`):** Aplicación React (`corlad-frontend`), arquitectura modular por features, custom hooks de estado, servicios Axios y lienzos interactivos (GSAP y Three.js).
> 3. **Diseño y Usabilidad (`/ui-bot`):** Herencia estricta de `components/base/`, consistencia de tokens de color (#007030, #F5A604, etc.), responsividad adaptativa y Three.js sin fugas de memoria.
> 4. **Base de Datos & Negocio:** Esquema SQL Server (`.antigravity/context/Script.sql`), restricciones de integridad referencial, transaccionalidad y flujogramas BPMN Bizagi.

---

## 2. MATRIZ INTEGRAL DE LAS 18 DIMENSIONES DE PRUEBAS

`/qa-bot` analiza, diseña y ejecuta una batería de pruebas exhaustiva estructurada en **18 tipos de pruebas normativas**:

| # | Tipo de Prueba | ¿Qué verifica? | Ámbito en CORLAD Junín | Herramienta / Técnica |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **Pruebas unitarias** | Cada función, cálculo o método individual de forma aislada. | Métodos de cálculo de cuotas ordinarias, multas por omisión al sufragio, reglas de fraccionamiento en `[MOD].FlujoTrabajo` y funciones puras de formateo en React (`formatoSoles`, `validarDNI`). | xUnit / NUnit (VB.NET), Vitest (React) |
| **2** | **Pruebas de integración** | Que varios componentes, capas y servicios funcionen juntos armónicamente. | Conexión `CORLAD.API` ↔ `[MOD].FlujoTrabajo` ↔ `[MOD].AccesoDatos` ↔ `SQL Server 2026`, ejecución de `SqlTransaction` con commit/rollback real y frontend consumiendo la API. | TestServer ASP.NET Core, Base de datos de prueba / TestContainers |
| **3** | **Pruebas funcionales** | Que una función o módulo institucional cumpla estrictamente con su especificación. | Registro de nueva colegiatura, cálculo automático del número de matrícula correlativo, emisión de constancia de habilitación y generación de ticket de atención. | Casos de prueba automatizados / xUnit + WebApplicationFactory |
| **4** | **Pruebas de aceptación (BDD)** | Que el sistema cumpla los requisitos de usuario definidos en las Historias de Usuario y Casos de Uso. | Escenarios expresados en sintaxis formal Gherkin (*Given-When-Then* / *Dado-Cuando-Entonces*) mapeados a los 5 documentos fuente (ERS, BPMN Bizagi). | SpecFlow / Cucumber / Gherkin |
| **5** | **Pruebas de regresión** | Que nuevas modificaciones o refactorizaciones no rompan funcionalidades preexistentes. | Confirmar que al modificar la estructura tarifaria de Caja (`CAJ`), no se altere el cálculo del padrón de colegiados hábiles (`CLI`) ni los asientos contables automáticos (`CNT`). | Suite automatizada de Regresión (CI/CD Pipeline) |
| **6** | **Pruebas de errores / excepciones** | Resiliencia y comportamiento del sistema ante condiciones anormales o fallos esperados. | Ingreso de DNI no registrado, colegiado suspendido por el Tribunal de Honor intentando votar, concurrencia en numeración de recibo o pérdida temporal de conexión a base de datos. | Aserciones de `AppException`, Códigos HTTP 400, 404, 409, 500 controlado |
| **7** | **Pruebas de validación** | Que las entradas de datos cumplan longitudes, tipos, rangos y formatos institucionales antes de persistir. | DNI exactamente de 8 dígitos numéricos, RUC de 11 dígitos, montos mayores a 0.00 en Soles, correos con formato RFC válido, campos obligatorios no nulos ni vacíos. | `FormRequest.Validar()` en backend, `BaseInput` / Zod / Yup en React |
| **8** | **Pruebas de seguridad** | Detección de vulnerabilidades, inyecciones, escalamiento de privilegios y accesos no autorizados. | Prevención de SQL Injection (comprobar uso estricto de parámetros fuertemente tipados), XSS sanitizado, validación de Bearer Token JWT, método `Authorize(rol)` y CORS. | OWASP ZAP, Inspección de código contra inyecciones, Pruebas de RBAC |
| **9** | **Pruebas de rendimiento** | Tiempos de respuesta, latencia de red y uso de recursos del sistema. | Percentil 95 (P95) de la Web API inferior a 200 ms, renderizado de React en menos de 16 ms por frame (60 FPS estables) y consumo de memoria controlado en Three.js. | Chrome DevTools Lighthouse, BenchmarkDotNet |
| **10** | **Pruebas de carga** | Comportamiento del sistema ante concurrencia normal y sostenida de usuarios. | Simulación de 100 a 500 agremiados y administrativos consultando simultáneamente el estado de habilidad y emitiendo comprobantes de pago. | k6 / Apache JMeter |
| **11** | **Pruebas de estrés** | Determinación del punto de saturación y quiebre de la infraestructura (*breaking point*). | Incremento continuo de solicitudes hasta saturar el pool de conexiones SQL Server (`Max Pool Size = 100`) o memoria de Kestrel, verificando recuperación elegante sin corrupción de datos. | k6 Ramp-up Stress Scenarios |
| **12** | **Pruebas de API REST** | Verificación estricta de contratos de interfaz, códigos de estado HTTP y estructura JSON. | Validación del envoltorio estándar `ApiResponse(Of T)`: `{ exito: Boolean, mensaje: String, codigoEstado: Int, datos: T, errores: List }`, cabeceras y métodos HTTP (GET, POST, PUT, DELETE). | Postman / Newman, SuperTest, xUnit Integration |
| **13** | **Pruebas de base de datos** | Integridad referencial, disparadores, llaves foráneas y consistencia ACID. | Verificación de restricciones `CK_`, `FK_`, anulación de operaciones en cascada indebidas, aislamiento de transacciones `SERIALIZABLE` en balance de caja y hash SHA-256 de seguridad. | T-SQL Scripts de aserción, DB Unit Tests |
| **14** | **Pruebas de interfaz (UI)** | Correcto funcionamiento, accesibilidad, estados e interactividad de la vista. | Deshabilitación de botones al enviar (`isLoading`), animación de sacudida (*shake effect*) ante error, captura y bloqueo de foco en `BaseModal`, navegación por teclado y contraste accesible. | React Testing Library + Vitest |
| **15** | **Pruebas E2E (End-to-End)** | Simulación automatizada del recorrido completo de los flujos de usuario de inicio a fin. | Flujo: Login de Agremiado ➔ Búsqueda de Trámite ➔ Pago simulado en Caja ➔ Generación de Factura ➔ Verificación en línea de Habilidad con Código QR. | Playwright / Cypress |
| **16** | **Análisis estático de código** | Detección de deuda técnica, vulnerabilidades, malas prácticas y complejidad sin ejecutar código. | Detección de código duplicado (violaciones DRY), métodos con complejidad ciclomática > 10, consultas SQL huérfanas, imports no utilizados y apego a Clean Code. | Roslyn Analyzers (.NET), ESLint / TypeScript Compiler (React), SonarQube rules |
| **17** | **Pruebas de cobertura** | Porcentaje de líneas, ramas y métodos cubiertos por pruebas automatizadas. | Meta obligatoria de cobertura institucional: **Mínimo 80% en Capa de Negocios (`FlujoTrabajo`), 85% en `FormRequests` de validación y 75% en componentes críticos**. | Coverlet (.NET), Istanbul / C8 / Vitest Coverage |
| **18** | **Pruebas de compatibilidad** | Funcionamiento y visualización idéntica en diversos motores de renderizado y dispositivos. | Ejecución idéntica en Google Chrome (Chromium), Microsoft Edge, Mozilla Firefox, Safari (WebKit) y adaptación en pantallas móviles (375px), tablets (768px), desktop y 4K (3840px). | Playwright Multi-Device Matrix, CrossBrowser Testing |

---

## 3. ESPECIFICACIÓN TÉCNICA DE PRUEBAS AUTOMATIZADAS (EJEMPLOS DE IMPLEMENTACIÓN)

Al implementar los artefactos de prueba, `/qa-bot` produce código de test robusto y ejecutable siguiendo las mejores prácticas:

### 3.1. Pruebas Unitarias y de Validación en Backend (.NET / xUnit)
```vb
<Fact>
Public Sub ValidarColegiadoFormRequest_DniInvalido_RetornaErrorValidacion()
    ' Arrange
    Dim request As New RegistrarColegiadoFormRequest With {
        .Dni = "12345", ' Menos de 8 dígitos
        .Nombres = "Carlos",
        .ApellidoPaterno = "Martínez",
        .ApellidoMaterno = "Gómez",
        .CorreoElectronico = "carlos@correo.com"
    }

    ' Act
    Dim resultado = request.Validar()

    ' Assert
    Assert.False(resultado.EsValido)
    Assert.Contains(resultado.Errores, Function(e) e.Campo = "Dni")
End Sub
```

### 3.2. Criterios de Aceptación BDD (Gherkin / Given-When-Then)
```gherkin
Característica: Emisión de Constancia de Habilidad Institucional
  Como Licenciado en Administración agremiado al CORLAD Junín
  Quiero consultar mi estado de habilidad institucional y descargar la constancia
  Para poder ejercer la profesión en convocatorias públicas y privadas

  Escenario: Agremiado al día en sus cuotas ordinarias
    Dado que el colegiado con matrícula "12045" tiene 0 cuotas vencidas
    Y no cuenta con sanciones disciplinarias activas en el Tribunal de Honor
    Cuando solicita la emisión de su constancia de habilidad
    Entonces el sistema debe responder con estado "HABIL"
    Y debe generar una constancia oficial con código de verificación QR y firma digital
    Y debe registrar la traza de auditoría en la tabla "GEN_Auditoria"
```

### 3.3. Pruebas E2E Automatizadas (Playwright)
```javascript
import { test, expect } from '@playwright/test';

test('Flujo E2E: Pago de cuota ordinaria y actualización de habilidad', async ({ page }) => {
  // 1. Login institucional
  await page.goto('/login');
  await page.fill('input[name="usuario"]', 'administracion@corladjunin.org.pe');
  await page.fill('input[name="password"]', 'ClaveSegura2026!');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');

  // 2. Navegación a Caja y cobro de cuota
  await page.click('a[href="/caj/cobranza"]');
  await page.fill('input[name="buscarColegiado"]', '10452367');
  await page.click('button:has-text("Buscar")');
  await page.click('input[type="checkbox"][data-cuota="2026-03"]');
  await page.click('button:has-text("Procesar Cobranza")');

  // 3. Confirmación en BaseModal y verificación de comprobante
  await expect(page.locator('.base-modal')).toBeVisible();
  await page.click('button:has-text("Confirmar Emisión")');
  await expect(page.locator('.base-notification')).toContainText('Comprobante emitido exitosamente');

  // 4. Verificación de estado de habilidad actualizado
  await page.goto('/cli/consulta-habilidad?dni=10452367');
  await expect(page.locator('.base-badge')).toContainText('HABIL');
});
```

### 3.4. Pruebas de Carga y Rendimiento (Script k6)
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 }, // Rampa ascendente a 100 usuarios
    { duration: '1m',  target: 300 }, // Carga sostenida de 300 usuarios
    { duration: '30s', target: 0 },   // Rampa de descenso
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% de las peticiones deben resolver en menos de 200ms
    http_req_failed: ['rate<0.01'],    // Tasa de fallos menor al 1%
  },
};

export default function () {
  const res = http.get('https://api.corladjunin.org.pe/api/cli/habilidad/10452367');
  check(res, {
    'código es 200': (r) => r.status === 200,
    'respuesta contiene éxito': (r) => JSON.parse(r.body).exito === true,
  });
  sleep(1);
}
```

---

## 4. INFORME DE CERTIFICACIÓN DE CALIDAD DE SOFTWARE (OUTPUT DE `/qa-bot`)

Cada vez que `/qa-bot` se ejecute, debe generar un informe estructurado que contenga:
1. **Resumen Ejecutivo de QA:** Número total de pruebas ejecutadas, aprobadas, fallidas y cobertura global.
2. **Tabla de Resultados de las 18 Pruebas:** Evaluación detallada dimensión por dimensión con sus respectivos estados `[PASS]`.
3. **Métricas de Rendimiento y Carga:** P95, RPS (Requests Per Second), consumo de memoria y FPS en Three.js.
4. **Vulnerabilidades y Seguridad:** Confirmación de 0 inyecciones SQL, 0 brechas XSS y RBAC verificado.
5. **Mensaje de Cierre y Pase al Siguiente Bot:** Declaración formal de certificación técnica satisfactoria y habilitación del siguiente bot del pipeline (DevOps / Deploy).

---

## 5. MENSAJE FINAL OBLIGATORIO DE ENTREGA (PASE AL SIGUIENTE BOT)

Al finalizar satisfactoriamente la validación y el pase de las pruebas, `/qa-bot` **debe concluir obligatoriamente con este bloque formal de entrega estandarizado**:

```markdown
---

### 📜 MENSAJE DE PASE AL SIGUIENTE BOT (FASE DE AUDITORÍA DE CALIDAD ISO/IEC 25010)
> [!NOTE]
> ### 🏆 **¡CERTIFICACIÓN DE CALIDAD DE SOFTWARE EXITOSA (100% PRUEBAS PASADAS)!**  
> Se ha ejecutado y validado satisfactoriamente la batería integral de **18 tipos de pruebas** sobre el ecosistema completo del CORLAD Junín (Backend en VB.NET N-Tier, Base de Datos SQL Server 2026, Frontend en React con GSAP/Three.js y Sistema de Diseño institucional).  
>  
> 📊 **RESUMEN DE CALIDAD Y COBERTURA TÉCNICA:**  
> - **Total de Pruebas Ejecutadas:** `[Número total, ej: 142]`  
> - **Pruebas Aprobadas:** `[Número, ej: 142]` (`100% PASS`) | **Fallidas:** `0`  
> - **Cobertura de Código (Code Coverage):** `[ej: 88.4%]` (Supera el umbral institucional del 80%)  
> - **Pruebas de Carga & Rendimiento (k6):** P95 = `[ej: 84ms]` (< 200ms) con `[ej: 300]` usuarios concurrentes  
> - **Seguridad & Vulnerabilidades (OWASP):** `0` SQL Injections, `0` XSS, RBAC y JWT 100% validados  
> - **Compatibilidad Multiplataforma:** Certificado en Chrome, Edge, Firefox, Safari, Android y monitores 4K  
>  
> 📋 **INSTRUCCIÓN PARA EL SIGUIENTE BOT (ISO-BOT / AUDITOR DE CALIDAD ISO/IEC 25010):**  
> *"Toma este release certificado con calidad de software garantizada y procede a auditar y verificar el estricto cumplimiento de los estándares internacionales de calidad ISO/IEC 25010, contrastando cada dimensión contra los umbrales mínimos de aceptación institucional."*
```
