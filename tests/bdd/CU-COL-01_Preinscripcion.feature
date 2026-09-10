# language: es
Característica: CU-COL-01 - Solicitar Pre-inscripción y Carga Digital de Requisitos de Colegiatura
  Como Licenciado en Administración graduado de universidad peruana o extranjera revalidada
  Quiero enviar mis datos de postulación y digitalizar mis 5 requisitos obligatorios
  Para que la Mesa de Partes del CORLAD Junín revise mi expediente e inicie mi proceso de colegiatura

  Antecedentes:
    Dado que el sistema de Mesa de Partes Digital del CORLAD Junín se encuentra operativo
    Y el servicio de verificación de integridad criptográfica SHA-256 está activo

  Escenario: Postulación exitosa con los 5 requisitos obligatorios en regla
    Dado que el postulante con DNI "72345678" y título emitido por "UNCP"
    Y adjunta los 5 documentos válidos:
      | Requisito    | Formato | Tamaño  |
      | REQ-DNI      | .pdf    | 512 KB  |
      | REQ-TIT      | .pdf    | 1.2 MB  |
      | REQ-SUN      | .pdf    | 600 KB  |
      | REQ-FOT      | .jpg    | 400 KB  |
      | REQ-DEC      | .pdf    | 300 KB  |
    Y acepta la declaración jurada de autenticidad institucional
    Cuando presiona el botón "Enviar Pre-inscripción al CORLAD Junín"
    Entonces el backend debe registrar la postulación de forma atómica en la base de datos
    Y debe calcular el hash SHA-256 inalterable para cada documento adjunto
    Y debe retornar código HTTP 201 Created con número correlativo formato "COL-2026-XXXXX"
    Y el estado del expediente debe ser "EST-ENV" (Enviado / Pendiente de Revisión)
    Y la interfaz debe mostrar la tarjeta de confirmación con opción a seguimiento

  Escenario: Intento de postulación con DNI inválido
    Dado que el postulante ingresa el número de documento "12345" con menos de 8 dígitos
    Cuando intenta enviar la solicitud
    Entonces el frontend activa la animación de sacudida (shake effect) en el formulario
    Y el campo DNI se resalta con borde rojo de error
    Y no se permite el envío de la petición HTTP al servidor

  Escenario: Intento de carga de archivo con extensión peligrosa no permitida
    Dado que el postulante intenta adjuntar un archivo con nombre "requisito.exe"
    Cuando lo suelta en el componente Drag & Drop de carga
    Entonces el sistema rechaza de inmediato el archivo indicando "Extensión no permitida (.exe)"
    Y exige archivos en formato PDF, JPG o PNG
