import React from 'react';
import { BaseCard } from '../../../components/base/BaseCard';
import { BaseForm } from '../../../components/base/BaseForm';
import { BaseInput } from '../../../components/base/BaseInput';
import { BaseSelect } from '../../../components/base/BaseSelect';
import { BaseDatePicker } from '../../../components/base/BaseDatePicker';
import { BaseFileUploader } from '../../../components/base/BaseFileUploader';
import { BaseButton } from '../../../components/base/BaseButton';
import { User, GraduationCap, UploadCloud, Send, FileText, CheckCircle2 } from 'lucide-react';

export const PreinscripcionForm = ({
  formData,
  documentos,
  errors,
  backendErrors,
  isSubmitting,
  handleInputChange,
  handleDocumentSelect,
  handleDocumentRemove,
  onSubmit,
}) => {
  return (
    <BaseForm onSubmit={onSubmit} isSubmitting={isSubmitting} backendErrors={backendErrors}>
      {/* SECCIÓN 1: DATOS PERSONALES */}
      <BaseCard
        title="1. Datos Personales del Postulante"
        subtitle="Ingrese la información del titular según constancia de RENIEC"
        icon={User}
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.25rem' }}>
          <BaseInput
            label="N° Documento Nacional de Identidad (DNI)"
            name="numeroDocumento"
            value={formData.numeroDocumento}
            onChange={handleInputChange}
            placeholder="8 dígitos numéricos"
            maxLength={8}
            required
            error={errors.numeroDocumento}
            helperText="Debe coincidir con su DNI escaneado"
          />

          <BaseSelect
            label="Sexo"
            name="sexo"
            value={formData.sexo}
            onChange={handleInputChange}
            required
            options={[
              { value: 'M', label: 'Masculino' },
              { value: 'F', label: 'Femenino' },
            ]}
          />

          <BaseDatePicker
            label="Fecha de Nacimiento"
            name="fechaNacimiento"
            value={formData.fechaNacimiento}
            onChange={handleInputChange}
            required
            error={errors.fechaNacimiento}
          />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.25rem', marginTop: '1.25rem' }}>
          <BaseInput
            label="Primer Nombre"
            name="primerNombre"
            value={formData.primerNombre}
            onChange={handleInputChange}
            placeholder="Ej. Jheferson"
            required
            error={errors.primerNombre}
          />

          <BaseInput
            label="Segundo Nombre"
            name="segundoNombre"
            value={formData.segundoNombre}
            onChange={handleInputChange}
            placeholder="Ej. David (Opcional)"
          />

          <BaseInput
            label="Apellido Paterno"
            name="apellidoPaterno"
            value={formData.apellidoPaterno}
            onChange={handleInputChange}
            placeholder="Ej. Martinez"
            required
            error={errors.apellidoPaterno}
          />

          <BaseInput
            label="Apellido Materno"
            name="apellidoMaterno"
            value={formData.apellidoMaterno}
            onChange={handleInputChange}
            placeholder="Ej. Castro"
            required
            error={errors.apellidoMaterno}
          />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.25rem', marginTop: '1.25rem' }}>
          <BaseInput
            label="Correo Electrónico de Contacto"
            name="correoElectronico"
            type="email"
            value={formData.correoElectronico}
            onChange={handleInputChange}
            placeholder="correo@ejemplo.com"
            required
            error={errors.correoElectronico}
            helperText="Aquí recibirá la confirmación y constancias"
          />

          <BaseInput
            label="Teléfono Móvil / WhatsApp"
            name="telefonoCelular"
            value={formData.telefonoCelular}
            onChange={handleInputChange}
            placeholder="9 dígitos (Ej. 987654321)"
            maxLength={9}
            required
            error={errors.telefonoCelular}
          />

          <BaseInput
            label="Dirección Domiciliaria"
            name="direccionLinea"
            value={formData.direccionLinea}
            onChange={handleInputChange}
            placeholder="Av. / Jr. / Calle, N°, Urb."
            required
            error={errors.direccionLinea}
          />
        </div>
      </BaseCard>

      {/* SECCIÓN 2: FORMACIÓN PROFESIONAL */}
      <BaseCard
        title="2. Información Académica y Registro SUNEDU"
        subtitle="Datos del Título Profesional en Administración expedido a nombre de la Nación"
        icon={GraduationCap}
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1.25rem' }}>
          <BaseInput
            label="Universidad de Procedencia"
            name="universidadOrigen"
            value={formData.universidadOrigen}
            onChange={handleInputChange}
            placeholder="Ej. Universidad Nacional del Centro del Perú"
            required
            error={errors.universidadOrigen}
          />

          <BaseInput
            label="Denominación del Título Profesional"
            name="tituloProfesional"
            value={formData.tituloProfesional}
            onChange={handleInputChange}
            placeholder="Ej. Licenciado en Administración"
            required
            error={errors.tituloProfesional}
          />

          <BaseInput
            label="N° Resolución Rectoral del Título"
            name="numeroResolucionTitulo"
            value={formData.numeroResolucionTitulo}
            onChange={handleInputChange}
            placeholder="Ej. RES-UNCP-2024-045"
            required
            error={errors.numeroResolucionTitulo}
          />

          <BaseDatePicker
            label="Fecha de Emisión del Título"
            name="fechaEmisionTitulo"
            value={formData.fechaEmisionTitulo}
            onChange={handleInputChange}
            required
            error={errors.fechaEmisionTitulo}
          />

          <BaseInput
            label="Código de Registro Nacional SUNEDU"
            name="codigoSunedu"
            value={formData.codigoSunedu}
            onChange={handleInputChange}
            placeholder="Ej. SUN-2024-998811"
            required
            error={errors.codigoSunedu}
            helperText="Verifique en el portal de títulos de SUNEDU"
          />
        </div>
      </BaseCard>

      {/* SECCIÓN 3: CARGA DIGITAL DE REQUISITOS (5 REQUISITOS OBLIGATORIOS) */}
      <BaseCard
        title="3. Carga Digital de Requisitos Obligatorios"
        subtitle="Digitalice y cargue los 5 documentos en formato PDF o JPG (Máx. 5MB cada uno)"
        icon={UploadCloud}
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.25rem' }}>
          <BaseFileUploader
            label="1. Copia de DNI legible (Ambas Caras)"
            required
            selectedFile={documentos['REQ-DNI']}
            error={errors['REQ-DNI']}
            onFileSelect={(f) => handleDocumentSelect('REQ-DNI', f)}
            onFileRemove={() => handleDocumentRemove('REQ-DNI')}
          />

          <BaseFileUploader
            label="2. Título Profesional Escaneado (Ambas Caras)"
            required
            selectedFile={documentos['REQ-TIT']}
            error={errors['REQ-TIT']}
            onFileSelect={(f) => handleDocumentSelect('REQ-TIT', f)}
            onFileRemove={() => handleDocumentRemove('REQ-TIT')}
          />

          <BaseFileUploader
            label="3. Constancia de Inscripción SUNEDU"
            required
            selectedFile={documentos['REQ-SUN']}
            error={errors['REQ-SUN']}
            onFileSelect={(f) => handleDocumentSelect('REQ-SUN', f)}
            onFileRemove={() => handleDocumentRemove('REQ-SUN')}
          />

          <BaseFileUploader
            label="4. Fotografía Formal (Terno, Fondo Blanco)"
            accept=".jpg,.jpeg,.png"
            required
            selectedFile={documentos['REQ-FOT']}
            error={errors['REQ-FOT']}
            helperText="Formato: JPG o PNG formal para carné y padrón"
            onFileSelect={(f) => handleDocumentSelect('REQ-FOT', f)}
            onFileRemove={() => handleDocumentRemove('REQ-FOT')}
          />

          <BaseFileUploader
            label="5. Declaración Jurada de No Tener Antecedentes"
            required
            selectedFile={documentos['REQ-DEC']}
            error={errors['REQ-DEC']}
            onFileSelect={(f) => handleDocumentSelect('REQ-DEC', f)}
            onFileRemove={() => handleDocumentRemove('REQ-DEC')}
          />
        </div>
      </BaseCard>

      {/* BOTÓN DE ENVÍO CON GSAP Y SPINNER */}
      <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: '1rem', marginTop: '1rem' }}>
        <BaseButton
          type="submit"
          variant="primary"
          size="lg"
          isLoading={isSubmitting}
          icon={Send}
        >
          Enviar Pre-inscripción al CORLAD Junín
        </BaseButton>
      </div>
    </BaseForm>
  );
};
