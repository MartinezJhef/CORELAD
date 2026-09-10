# language: es
Característica: CU-COL-03 - Asignar Matrícula Regional y Emitir Carnet
  Como Decano Regional o Secretaria Regional del CORLAD Junín
  Quiero formalizar la matrícula regional e incorporar al profesional al Padrón Oficial
  Para emitir la credencial institucional digital con código QR dinámico y firma digital conforme a la Ley 31060

  Antecedentes:
    Dado que el módulo de Colegiatura, Padrón y Habilitación (CLI) se encuentra activo
    Y el expediente de colegiatura cuenta con dictamen "APROBADO" y título verificado en SUNEDU
    Y la autoridad directiva autenticada cuenta con el rol "ROL-DEC" (Decano Regional) o "ROL-SEC" (Secretaria Regional)

  Escenario: Formalización de colegiatura exitosa con generación de matrícula correlativa y carnet digital
    Dado que existe un expediente aprobado con código "COL-2026-00010" del postulante "ROJAS CONDOR, JUAN CARLOS"
    Y la Decanatura visualiza el expediente en la "Bandeja de Aprobados Listos para Matrícula"
    Cuando la autoridad presiona el botón "Asignar Matrícula"
    Entonces el sistema despliega el modal interactivo con la matrícula sugerida "CORLAD-JUN-00128"
    Y la autoridad verifica el N° de Resolución Decanal "RES-DEC-045-2026-CORLAD-JUN" y la fecha de juramentación
    Y presiona "Formalizar y Emitir Carnet"
    Entonces el backend persiste la transacción ACID en [Colegiatura].[Colegiado] asignando estado "HABIL"
    Y actualiza el expediente a "INCORPORADO" con número de resolución
    Y genera el Carnet Digital con código QR dinámico y hash criptográfico SHA-256 de 64 caracteres
    Y la interfaz muestra el visor 3D interactivo con Anverso y Reverso (QR) y notificación de éxito

  Escenario: Prevención de conflicto por matrícula regional duplicada (Regla RN-COL-03)
    Dado que la autoridad directiva ingresa manualmente una matrícula "CORLAD-JUN-00125" ya asignada a otro agremiado
    Cuando presiona "Formalizar y Emitir Carnet"
    Entonces el backend ejecuta la verificación de unicidad en la tabla [Colegiatura].[Colegiado]
    Y detecta que la matrícula ya existe
    Y rechaza la operación retornando código HTTP 409 Conflict con mensaje "La matrícula regional ya se encuentra registrada"
    Y el sistema mantiene abierto el formulario resaltando el campo en rojo sin alterar el estado del expediente

  Escenario: Validación de obligatoriedad de Resolución Decanal y fecha protocolar
    Dado que se abre el formulario de formalización de colegiatura
    Cuando la autoridad intenta enviar el formulario dejando la Resolución Decanal en blanco
    Entonces el método AsignarMatriculaFormRequest.Validar() intercepta la petición
    Y retorna error de validación HTTP 400 en el campo "NumeroResolucionIncorporacion"
    Y la interfaz sacude el contenedor con animación GSAP y muestra el mensaje de obligatoriedad

  Escenario: Control de Acceso RBAC - Restricción a roles sin facultades directivas
    Dado que un usuario autenticado con rol "ROL-POSTULANTE" o "ROL-AGR" intenta invocar el endpoint POST "/api/cli/matricula/asignar"
    Cuando la petición HTTP llega a la Capa de Negocios
    Entonces el método AsignarMatriculaFormRequest.Authorize() deniega la autorización
    Y la API REST retorna código HTTP 403 Forbidden con mensaje "Acceso denegado. Se requiere rol directivo autorizado"
