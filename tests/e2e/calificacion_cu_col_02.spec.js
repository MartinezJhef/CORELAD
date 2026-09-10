import { test, expect } from '@playwright/test';

test.describe('CU-COL-02: Validar Título Profesional en SUNEDU y Calificación de Expediente', () => {

  test('Flujo E2E Completo: Carga de bandeja, verificación en tiempo real en SUNEDU y dictamen APROBADO', async ({ page }) => {
    // 1. Acceder a la plataforma institucional
    await page.goto('http://localhost:5173/');
    await expect(page).toHaveTitle(/CORLAD Junín/);

    // 2. Verificar que los 4 KPIs de la Secretaría Regional estén visibles
    await expect(page.locator('text=Expedientes por Calificar')).toBeVisible();
    await expect(page.locator('text=Tasa Verificación SUNEDU')).toBeVisible();
    await expect(page.locator('text=SLA de Respuesta')).toBeVisible();
    await expect(page.locator('text=Conformidad Documentaria')).toBeVisible();

    // 3. Ubicar el expediente en la tabla y abrir el modal de auditoría técnica
    const auditarBtn = page.locator('button:has-text("Auditar & Calificar")').first();
    await expect(auditarBtn).toBeVisible();
    await auditarBtn.click();

    // 4. Verificar que el modal de auditoría se abra con el legajo y el componente 3D
    await expect(page.locator('text=Auditoría Técnica: Expediente')).toBeVisible();
    await expect(page.locator('text=Registro Nacional de Grados y Títulos (SUNEDU)')).toBeVisible();

    // 5. Ejecutar la interoperabilidad en vivo con SUNEDU
    const consultarSuneduBtn = page.locator('button:has-text("Consultar en Vivo")');
    await expect(consultarSuneduBtn).toBeVisible();
    await consultarSuneduBtn.click();

    // 6. Verificar que SUNEDU responda con título verificado
    await expect(page.locator('text=TÍTULO REGISTRADO Y VIGENTE')).toBeVisible({ timeout: 5000 });

    // 7. Seleccionar dictamen APROBADO y confirmar
    const radioAprobado = page.locator('label:has-text("APROBADO")');
    await radioAprobado.click();

    const confirmarBtn = page.locator('button:has-text("Confirmar Dictamen (APROBADO)")');
    await expect(confirmarBtn).toBeEnabled();
    await confirmarBtn.click();

    // 8. Verificar que el modal se cierre tras calificar exitosamente
    await expect(page.locator('text=Auditoría Técnica: Expediente')).not.toBeVisible();
  });

  test('Regla RN-COL-02: Impedir aprobación del expediente si SUNEDU no ha sido consultado', async ({ page }) => {
    await page.goto('http://localhost:5173/');

    // Abrir modal de auditoría
    const auditarBtn = page.locator('button:has-text("Auditar & Calificar")').first();
    await auditarBtn.click();

    // Seleccionar opción APROBADO directamente sin consultar SUNEDU
    const radioAprobado = page.locator('label:has-text("APROBADO")');
    await radioAprobado.click();

    // Verificar que se muestre la advertencia institucional de la Ley 31060 (RN-COL-02)
    await expect(page.locator('text=Regla de Negocio RN-COL-02:')).toBeVisible();

    // Verificar que el botón de confirmación esté estrictamente deshabilitado
    const confirmarBtn = page.locator('button:has-text("Confirmar Dictamen (APROBADO)")');
    await expect(confirmarBtn).toBeDisabled();
  });

  test('Dictamen OBSERVADO: Exige motivo detallado para notificar al postulante', async ({ page }) => {
    await page.goto('http://localhost:5173/');

    const auditarBtn = page.locator('button:has-text("Auditar & Calificar")').first();
    await auditarBtn.click();

    // Seleccionar opción OBSERVADO
    const radioObservado = page.locator('label:has-text("OBSERVADO")');
    await radioObservado.click();

    // Verificar que aparezca el campo obligatorio de motivo
    const textareaMotivo = page.locator('textarea[placeholder*="correcciones requeridas"]');
    await expect(textareaMotivo).toBeVisible();

    // Ingresar motivo de observación
    await textareaMotivo.fill('Copia del DNI presenta baja resolución en el reverso. Subsanar en 5 días hábiles.');

    const confirmarBtn = page.locator('button:has-text("Confirmar Dictamen (OBSERVADO)")');
    await expect(confirmarBtn).toBeEnabled();
  });

});
