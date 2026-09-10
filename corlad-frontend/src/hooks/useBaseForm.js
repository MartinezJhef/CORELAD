import { useState, useCallback } from 'react';

export const useBaseForm = ({
  initialValues = {},
  validate = () => ({}),
  onSubmit,
}) => {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [backendErrors, setBackendErrors] = useState([]);

  const handleChange = useCallback((e) => {
    const { name, value, type, checked } = e.target;
    setValues((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
    // Limpiar error del campo al escribir
    if (errors[name]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[name];
        return next;
      });
    }
  }, [errors]);

  const setFieldValue = useCallback((name, value) => {
    setValues((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[name];
        return next;
      });
    }
  }, [errors]);

  const handleSubmit = async (e) => {
    if (e) e.preventDefault();
    setBackendErrors([]);

    const validationErrors = validate(values);
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      return { success: false, errors: validationErrors };
    }

    setIsSubmitting(true);
    try {
      if (onSubmit) {
        const res = await onSubmit(values);
        setIsSubmitting(false);
        return { success: true, data: res };
      }
      setIsSubmitting(false);
      return { success: true };
    } catch (err) {
      setIsSubmitting(false);
      if (err?.erroresValidacion && Array.isArray(err.erroresValidacion)) {
        setBackendErrors(err.erroresValidacion);
        // Mapear a campos locales si coinciden
        const fieldErrors = {};
        err.erroresValidacion.forEach((be) => {
          if (be.campo) {
            fieldErrors[be.campo] = be.mensaje;
          }
        });
        if (Object.keys(fieldErrors).length > 0) {
          setErrors((prev) => ({ ...prev, ...fieldErrors }));
        }
      }
      return { success: false, error: err };
    }
  };

  const resetForm = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setBackendErrors([]);
    setIsSubmitting(false);
  }, [initialValues]);

  return {
    values,
    errors,
    isSubmitting,
    backendErrors,
    handleChange,
    setFieldValue,
    handleSubmit,
    resetForm,
    setErrors,
    setBackendErrors,
  };
};
