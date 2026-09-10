import { useState, useCallback } from 'react';
import colegiaturaApi from '../services/colegiaturaApi';
import { useNotification } from '../../../hooks/useNotification';

const INITIAL_FORM_STATE = {
  numeroDocumento: '',
  primerNombre: '',
  segundoNombre: '',
  apellidoPaterno: '',
  apellidoMaterno: '',
  fechaNacimiento: '',
  sexo: 'M',
  correoElectronico: '',
  telefonoCelular: '',
  direccionLinea: '',
  distritoUbigeo: '120114', // Huancayo por defecto
  universidadOrigen: '',
  tituloProfesional: 'Licenciado en Administración',
  numeroResolucionTitulo: '',
  fechaEmisionTitulo: '',
  codigoSunedu: '',
};

export const usePreinscripcion = () => {
  const { notify } = useNotification();
  const [formData, setFormData] = useState(INITIAL_FORM_STATE);
  const [documentos, setDocumentos] = useState({});
  const [errors, setErrors] = useState({});
  const [backendErrors, setBackendErrors] = useState([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [expedienteCreado, setExpedienteCreado] = useState(null);

  const handleInputChange = useCallback((e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[name];
        return next;
      });
    }
  }, [errors]);

  const handleDocumentSelect = useCallback((tipoCodigo, fileData) => {
    setDocumentos((prev) => ({ ...prev, [tipoCodigo]: fileData }));
    if (errors[tipoCodigo]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[tipoCodigo];
        return next;
      });
    }
  }, [errors]);

  const handleDocumentRemove = useCallback((tipoCodigo) => {
    setDocumentos((prev) => {
      const next = { ...prev };
      delete next[tipoCodigo];
      return next;
    });
  }, []);

  const validarFormulario = () => {
    const errs = {};

    // Validar DNI
    if (!formData.numeroDocumento || !/^\d{8}$/.test(formData.numeroDocumento.trim())) {
      errs.numeroDocumento = 'El DNI debe contener exactamente 8 dígitos numéricos.';
    }

    // Nombres y Apellidos
    if (!formData.primerNombre.trim()) errs.primerNombre = 'El primer nombre es obligatorio.';
    if (!formData.apellidoPaterno.trim()) errs.apellidoPaterno = 'El apellido paterno es obligatorio.';
    if (!formData.apellidoMaterno.trim()) errs.apellidoMaterno = 'El apellido materno es obligatorio.';
    if (!formData.fechaNacimiento) errs.fechaNacimiento = 'La fecha de nacimiento es requerida.';

    // Contacto
    if (!formData.correoElectronico.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.correoElectronico.trim())) {
      errs.correoElectronico = 'Ingrese un correo electrónico válido.';
    }
    if (!formData.telefonoCelular.trim() || !/^\d{9}$/.test(formData.telefonoCelular.trim())) {
      errs.telefonoCelular = 'El celular debe tener 9 dígitos numéricos.';
    }
    if (!formData.direccionLinea.trim()) errs.direccionLinea = 'La dirección domiciliaria es obligatoria.';

    // Título Universitario
    if (!formData.universidadOrigen.trim()) errs.universidadOrigen = 'La universidad de procedencia es requerida.';
    if (!formData.tituloProfesional.trim()) errs.tituloProfesional = 'El título profesional es requerido.';
    if (!formData.numeroResolucionTitulo.trim()) errs.numeroResolucionTitulo = 'El número de resolución es obligatorio.';
    if (!formData.fechaEmisionTitulo) errs.fechaEmisionTitulo = 'La fecha de emisión del título es obligatoria.';
    if (!formData.codigoSunedu.trim()) errs.codigoSunedu = 'El código de registro SUNEDU es requerido.';

    // Documentos Obligatorios
    const docsObligatorios = [
      { codigo: 'REQ-DNI', label: 'Copia de DNI' },
      { codigo: 'REQ-TIT', label: 'Título Profesional escaneado' },
      { codigo: 'REQ-SUN', label: 'Constancia de Registro SUNEDU' },
      { codigo: 'REQ-FOT', label: 'Fotografía formal fondo blanco' },
      { codigo: 'REQ-DEC', label: 'Declaración Jurada firmada' },
    ];

    docsObligatorios.forEach((d) => {
      if (!documentos[d.codigo]) {
        errs[d.codigo] = `Debe adjuntar el archivo de: ${d.label}.`;
      }
    });

    return errs;
  };

  const enviarPreinscripcion = async (e) => {
    if (e) e.preventDefault();
    setBackendErrors([]);

    const valErrors = validarFormulario();
    if (Object.keys(valErrors).length > 0) {
      setErrors(valErrors);
      notify.error('Por favor revise los campos observados en el formulario', 'Datos Incompletos');
      return;
    }

    setIsSubmitting(true);
    try {
      // Transformar documentos para el payload
      const listaDocumentos = Object.entries(documentos).map(([tipoCodigo, doc]) => ({
        codigoTipoDocumento: tipoCodigo,
        nombreOriginal: doc.nombreOriginal,
        extension: doc.extension,
        tamanoBytes: doc.tamanoBytes,
        archivoBase64: doc.archivoBase64,
      }));

      const payload = {
        ...formData,
        documentos: listaDocumentos,
      };

      const response = await colegiaturaApi.registrarPreinscripcion(payload);

      if (response.exito && response.datos) {
        setExpedienteCreado(response.datos);
        notify.success(response.mensaje, '¡Expediente Generado con Éxito!');
      } else {
        notify.warning(response.mensaje || 'No se pudo completar el registro', 'Atención');
      }
    } catch (err) {
      if (err.erroresValidacion && err.erroresValidacion.length > 0) {
        setBackendErrors(err.erroresValidacion);
        notify.error('Existen observaciones que corregir en el expediente', 'Observaciones');
      } else {
        notify.error(err.mensaje || 'Error al conectar con la Mesa de Partes', 'Error de Conexión');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const reiniciarTramite = () => {
    setFormData(INITIAL_FORM_STATE);
    setDocumentos({});
    setErrors({});
    setBackendErrors([]);
    setExpedienteCreado(null);
  };

  return {
    formData,
    documentos,
    errors,
    backendErrors,
    isSubmitting,
    expedienteCreado,
    handleInputChange,
    handleDocumentSelect,
    handleDocumentRemove,
    enviarPreinscripcion,
    reiniciarTramite,
  };
};
