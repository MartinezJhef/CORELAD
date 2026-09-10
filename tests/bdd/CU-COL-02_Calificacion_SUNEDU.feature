# language: es
Característica: CU-COL-02 - Validar Título Profesional en SUNEDU y Calificación de Expediente
  Como Secretaría Regional o miembro de la Comisión Evaluadora de Colegiatura
  Quiero auditar el legajo documental y verificar en tiempo real la autenticidad del título en SUNEDU
  Para emitir el dictamen técnico vinculante (Aprobado, Observado o Rechazado) conforme a la Ley 31060

  Antecedentes:
    Dado que el módulo de Colegiatura, Padrón y Habilitación (CLI) se encuentra activo
    Y el protocolo de interoperabilidad con el Registro Nacional de Grados y Títulos de SUNEDU vía PIDE está habilitado
    Y la funcionaria autenticada cuenta con el rol "ROL-SEC" (Secretaría Regional)

  Escenario: Calificación favorable con contrastación positiva en SUNEDU y dictamen APROBADO
    Dado que existe un expediente pendiente con código "COL-2026-00001" y DNI "72345678"
    Y la funcionaria selecciona "Auditar & Calificar" en la bandeja técnica
    Cuando presiona el botón "Consultar en Vivo" ante SUNEDU
    Entonces el servicio retorna validación positiva con título "LICENCIADO EN ADMINISTRACION" de la "UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU"
    Y el Escudo 3D Three.js se ilumina con acento dorado y verde de fe pública
    Y al marcar la conformidad de los 5 requisitos del legajo digital
    Y seleccionar el dictamen "APROBADO" y confirmar
    Entonces el backend actualiza el estado del expediente a "APROBADO"
    Y registra la traza de verificación en la tabla [Colegiatura].[TituloProfesional] con fecha y código SUNEDU
    Y el sistema emite notificación toast de éxito y retira el expediente de la bandeja de pendientes

  Escenario: Intento de aprobación sin verificación previa en SUNEDU bloqueado por Regla RN-COL-02
    Dado que existe un expediente "COL-2026-00002" sin contrastación positiva en SUNEDU
    Cuando la evaluadora intenta seleccionar el dictamen "APROBADO" sin consultar SUNEDU
    Entonces la interfaz despliega la advertencia institucional de la Regla RN-COL-02
    Y el botón "Confirmar Dictamen (APROBADO)" permanece deshabilitado
    Y si se envía la petición HTTP forzada directamente al endpoint REST
    Entonces el FormRequest backend rechaza la solicitud retornando HTTP 422 con error "No procede la aprobación sin verificación en SUNEDU"

  Escenario: Emisión de dictamen OBSERVADO con motivo detallado de subsanación
    Dado que en el expediente "COL-2026-00003" el postulante adjuntó un certificado de antecedentes ilegible
    Cuando la evaluadora desmarca la conformidad del documento "CERTIFICADO_ANTECEDENTES"
    Y selecciona el dictamen "OBSERVADO"
    Y redacta el motivo: "El certificado de antecedentes penales no presenta firma digital válida ni fecha legible"
    Y presiona "Confirmar Dictamen (OBSERVADO)"
    Entonces el sistema actualiza el estado a "OBSERVADO"
    Y envía la notificación formal al correo electrónico del postulante con el plazo de subsanación de 5 días hábiles

  Escenario: Control de Acceso RBAC - Usuario con rol no autorizado intentando dictaminar
    Dado que un usuario autenticado con rol "ROL-POSTULANTE" o externo intenta invocar el endpoint POST "/api/cli/calificacion/dictaminar"
    Cuando la petición llega a la Capa de Negocios
    Entonces el método CalificarExpedienteFormRequest.Authorize() evalúa el rol
    Y retorna falso con código HTTP 403 Forbidden y mensaje "No cuenta con privilegios para calificar expedientes de colegiatura"
