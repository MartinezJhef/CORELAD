import { test, expect } from '@playwright/test';

test.describe('CU-COL-03: Asignar Matrícula Regional y Emitir Carnet Oficial', () => {

  test('Flujo E2E Completo: Consulta de aprobados, modal de formalización, alta en padrón y carnet 3D', async ({ page }) => {
    // 1. Acceder al sistema
    await page.goto('http://localhost:5173/');
    await expect(page).toHaveTitle(/CORLAD Junín/);

    // 2. Navegar a la pestaña "3. Matrícula & Carnet (Decanatura)" si no está activa
    const tabMatricula = page.locator('button:has-text("3. Matrícula & Carnet")');
    if (await tabMatricula.isVisible()) {
      await tabMatricula.click();
    }

    // 3. Verificar KPIs y Medallón 3D
    await expect(page.locator('text=Expedientes Listos para Matrícula')).toBeVisible();
    await expect(page.locator('text=Próxima Matrícula Regional')).toBeVisible();
    await expect(page.locator('text=Padrón de Colegiados 2026')).toBeVisible();

    // 4. Ubicar primer expediente aprobado en la tabla
    const asignarBtn = page.locator('button:has-text("Asignar Matrícula")').first();
    await expect(asignarBtn).toBeVisible();
    await asignarBtn.click();

    // 5. Verificar que se abra el Modal de Asignación con datos cargados
    await expect(page.locator('text=Formalización de Matrícula Regional')).toBeVisible();
    await expect(page.locator('input[name="matriculaRegional"]')).toBeVisible();
    await expect(page.locator('input[name="numeroResolucionIncorporacion"]')).toBeVisible();

    // 6. Confirmar la formalización y emisión
    const submitBtn = page.locator('button:has-text("Formalizar y Emitir Carnet")');
    await expect(submitBtn).toBeVisible();
    await submitBtn.click();

    // 7. Verificar que se abra el visor interactivo de Carnet Oficial Digital
    await expect(page.locator('text=Carnet Oficial del Colegiado')).toBeVisible({ timeout: 5000 });
    await expect(page.locator('text=MATRÍCULA REGIONAL JUNÍN')).toBeVisible();
    await expect(page.locator('text=TITULADO')).toBeVisible();

    // 8. Probar el giro 3D a la cara de Reverso (QR & Firmas)
    const reversoBtn = page.locator('button:has-text("Reverso (QR & Firmas)")');
    await expect(reversoBtn).toBeVisible();
    await reversoBtn.click();

    // 9. Verificar presencia de QR dinámico y Hash SHA-256
    await expect(page.locator('text=VALIDACIÓN DE HABILIDAD Y EJERCICIO PROFESIONAL')).toBeVisible();
    await expect(page.locator('text=HASH CRIPTOGRÁFICO DE AUTENTICIDAD')).toBeVisible();
    await expect(page.locator('img[alt="QR Validación"]')).toBeVisible();

    // 10. Probar copiado de hash
    const copiarHashBtn = page.locator('button[title="Copiar Hash"]');
    await expect(copiarHashBtn).toBeVisible();
    await copiarHashBtn.click();
  });

  test('Validación: Campo obligatorio de Resolución Decanal', async ({ page }) => {
    await page.goto('http://localhost:5173/');

    const tabMatricula = page.locator('button:has-text("3. Matrícula & Carnet")');
    if (await tabMatricula.isVisible()) {
      await tabMatricula.click();
    }

    const asignarBtn = page.locator('button:has-text("Asignar Matrícula")').first();
    await asignarBtn.click();

    // Limpiar el campo de resolución decanal
    const resolucionInput = page.locator('input[name="numeroResolucionIncorporacion"]');
    await resolucionInput.fill('');

    const submitBtn = page.locator('button:has-text("Formalizar y Emitir Carnet")');
    await submitBtn.click();

    // Verificar error en pantalla
    await expect(page.locator('text=El número de resolución decanal es mandatorio')).toBeVisible();
  });
});
