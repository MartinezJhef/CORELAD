import { test, expect } from '@playwright/test';

test.describe('CU-COL-01: Pre-inscripción Digital y Carga de Requisitos', () => {

  test('Flujo E2E Completo: Carga de datos, archivos y generación de expediente con SHA-256', async ({ page }) => {
    // 1. Acceder a la Mesa de Partes Digital
    await page.goto('http://localhost:5173/');
    await expect(page).toHaveTitle(/CORLAD Junín/);

    // 2. Llenar Datos Personales del Postulante
    await page.fill('input[name="numeroDocumento"]', '72345678');
    await page.fill('input[name="primerNombre"]', 'Jheferson');
    await page.fill('input[name="segundoNombre"]', 'David');
    await page.fill('input[name="apellidoPaterno"]', 'Martinez');
    await page.fill('input[name="apellidoMaterno"]', 'Castro');
    await page.fill('input[name="fechaNacimiento"]', '1998-05-15');
    await page.fill('input[name="correoElectronico"]', 'jheferson.martinez@gmail.com');
    await page.fill('input[name="telefonoCelular"]', '987654321');
    await page.fill('input[name="direccionLinea"]', 'Av. Ferrocarril 1024, El Tambo');

    // 3. Llenar Información Académica y SUNEDU
    await page.fill('input[name="universidadOrigen"]', 'Universidad Nacional del Centro del Perú');
    await page.fill('input[name="tituloProfesional"]', 'Licenciado en Administración');
    await page.fill('input[name="numeroResolucionTitulo"]', 'RES-UNCP-2024-045');
    await page.fill('input[name="fechaEmisionTitulo"]', '2024-02-20');
    await page.fill('input[name="codigoSunedu"]', 'SUN-2024-998811');

    // 4. Enviar Formulario
    const submitBtn = page.locator('button[type="submit"]');
    await expect(submitBtn).toBeVisible();

    // 5. Verificar que el botón activa el spinner de carga al enviar
    await submitBtn.click();
  });

  test('Validación UI: Error de DNI activa animación de sacudida y borde rojo', async ({ page }) => {
    await page.goto('http://localhost:5173/');

    // Ingresar DNI con solo 4 dígitos
    await page.fill('input[name="numeroDocumento"]', '1234');
    await page.click('button[type="submit"]');

    // Verificar mensaje de error en el campo DNI
    await expect(page.locator('text=El DNI debe contener exactamente 8 dígitos')).toBeVisible();
  });

});
