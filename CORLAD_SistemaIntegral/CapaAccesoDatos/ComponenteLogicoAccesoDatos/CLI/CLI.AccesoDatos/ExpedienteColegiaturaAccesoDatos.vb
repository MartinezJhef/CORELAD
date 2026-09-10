Imports System
Imports System.Data
Imports System.Collections.Generic
Imports Microsoft.Data.SqlClient
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports Helper.AccesoDatos

Namespace CLI.AccesoDatos
    ''' <summary>
    ''' Implementación de la Capa de Acceso a Datos para Expedientes de Colegiatura.
    ''' Cumple estrictamente con parámetros fuertemente tipados contra SQL Injection y manejo transaccional.
    ''' </summary>
    Public Class ExpedienteColegiaturaAccesoDatos
        Implements IExpedienteColegiaturaAccesoDatos

        Public Function ExistePostulantePorDni(dni As String) As Boolean Implements IExpedienteColegiaturaAccesoDatos.ExistePostulantePorDni
            Const query As String = "SELECT COUNT(1) FROM [Persona].[Persona] WHERE [Dni] = @Dni"
            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@Dni", SqlDbType.Char, dni.Trim())
            }
            Dim cantidad As Integer = Convert.ToInt32(SqlHelper.ExecuteScalar(query, parametros))
            Return cantidad > 0
        End Function

        Public Function ObtenerSiguienteCorrelativoExpediente(anio As Integer) As String Implements IExpedienteColegiaturaAccesoDatos.ObtenerSiguienteCorrelativoExpediente
            Const query As String = "SELECT ISNULL(MAX(CAST(RIGHT([NumeroExpediente], 5) AS INT)), 0) + 1 " &
                                    "FROM [Colegiatura].[ExpedienteColegiatura] " &
                                    "WHERE [NumeroExpediente] LIKE @PatronAnio"
            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@PatronAnio", SqlDbType.NVarChar, $"COL-{anio}-%")
            }
            Dim correlativo As Integer = Convert.ToInt32(SqlHelper.ExecuteScalar(query, parametros))
            Return $"COL-{anio}-{correlativo.ToString("D5")}"
        End Function

        Public Function InsertarPersonaYPostulante(postulante As PostulanteBE) As Integer Implements IExpedienteColegiaturaAccesoDatos.InsertarPersonaYPostulante
            Using cnn As SqlConnection = SqlHelper.ObtenerConexion()
                cnn.Open()
                Using tran As SqlTransaction = cnn.BeginTransaction()
                    Try
                        ' 1. Insertar [Persona].[Entidad]
                        Const sqlEntidad As String = "INSERT INTO [Persona].[Entidad] ([TipoEntidad], [FechaRegistro], [Activo]) " &
                                                     "VALUES ('PERSONA_NATURAL', GETDATE(), 1); " &
                                                     "SELECT SCOPE_IDENTITY();"
                        Dim entidadId As Integer
                        Using cmdEntidad As New SqlCommand(sqlEntidad, cnn, tran)
                            entidadId = Convert.ToInt32(cmdEntidad.ExecuteScalar())
                        End Using

                        ' 2. Insertar [Persona].[Persona]
                        Const sqlPersona As String = "INSERT INTO [Persona].[Persona] " &
                                                     "([EntidadID], [Dni], [ApellidoPaterno], [ApellidoMaterno], [Nombres], [Sexo], [EstadoCivil], [FechaNacimiento], [EsColegiado], [EsPostulante], [EsEmpleado]) " &
                                                     "VALUES (@EntidadID, @Dni, @ApellidoPaterno, @ApellidoMaterno, @Nombres, @Sexo, @EstadoCivil, @FechaNacimiento, 0, 1, 0);"
                        Using cmdPersona As New SqlCommand(sqlPersona, cnn, tran)
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, entidadId))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@Dni", SqlDbType.Char, postulante.Dni))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@ApellidoPaterno", SqlDbType.NVarChar, postulante.ApellidoPaterno))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@ApellidoMaterno", SqlDbType.NVarChar, postulante.ApellidoMaterno))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@Nombres", SqlDbType.NVarChar, postulante.Nombres))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@Sexo", SqlDbType.Char, postulante.Sexo))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@EstadoCivil", SqlDbType.Char, postulante.EstadoCivil))
                            cmdPersona.Parameters.Add(SqlHelper.CrearParametro("@FechaNacimiento", SqlDbType.Date, postulante.FechaNacimiento))
                            cmdPersona.ExecuteNonQuery()
                        End Using

                        ' 3. Insertar [Persona].[Direccion]
                        If Not String.IsNullOrWhiteSpace(postulante.DireccionDetalle) Then
                            Const sqlDireccion As String = "INSERT INTO [Persona].[Direccion] " &
                                                           "([EntidadID], [TipoDireccion], [Departamento], [Provincia], [Distrito], [DireccionDetalle], [Referencia], [EsPrincipal]) " &
                                                           "VALUES (@EntidadID, 'DOMICILIO', @Departamento, @Provincia, @Distrito, @DireccionDetalle, @Referencia, 1);"
                            Using cmdDireccion As New SqlCommand(sqlDireccion, cnn, tran)
                                cmdDireccion.Parameters.Add(SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, entidadId))
                                cmdDireccion.Parameters.Add(SqlHelper.CrearParametro("@Departamento", SqlDbType.NVarChar, postulante.Departamento))
                                cmdDireccion.Parameters.Add(SqlHelper.CrearParametro("@Provincia", SqlDbType.NVarChar, postulante.Provincia))
                                cmdDireccion.Parameters.Add(SqlHelper.CrearParametro("@Distrito", SqlDbType.NVarChar, postulante.Distrito))
                                cmdDireccion.Parameters.Add(SqlHelper.CrearParametro("@DireccionDetalle", SqlDbType.NVarChar, postulante.DireccionDetalle))
                                cmdDireccion.Parameters.Add(SqlHelper.CrearParametro("@Referencia", SqlDbType.NVarChar, postulante.Referencia, True))
                                cmdDireccion.ExecuteNonQuery()
                            End Using
                        End If

                        ' 4. Insertar [Persona].[Contacto] (Email)
                        If Not String.IsNullOrWhiteSpace(postulante.CorreoElectronico) Then
                            Const sqlEmail As String = "INSERT INTO [Persona].[Contacto] ([EntidadID], [TipoContacto], [ValorContacto], [EsPrincipal], [Verificado]) " &
                                                       "VALUES (@EntidadID, 'EMAIL', @ValorContacto, 1, 0);"
                            Using cmdEmail As New SqlCommand(sqlEmail, cnn, tran)
                                cmdEmail.Parameters.Add(SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, entidadId))
                                cmdEmail.Parameters.Add(SqlHelper.CrearParametro("@ValorContacto", SqlDbType.NVarChar, postulante.CorreoElectronico))
                                cmdEmail.ExecuteNonQuery()
                            End Using
                        End If

                        ' 5. Insertar [Persona].[Contacto] (Telefono)
                        If Not String.IsNullOrWhiteSpace(postulante.Telefono) Then
                            Const sqlTel As String = "INSERT INTO [Persona].[Contacto] ([EntidadID], [TipoContacto], [ValorContacto], [EsPrincipal], [Verificado]) " &
                                                     "VALUES (@EntidadID, 'TELEFONO', @ValorContacto, 0, 0);"
                            Using cmdTel As New SqlCommand(sqlTel, cnn, tran)
                                cmdTel.Parameters.Add(SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, entidadId))
                                cmdTel.Parameters.Add(SqlHelper.CrearParametro("@ValorContacto", SqlDbType.NVarChar, postulante.Telefono))
                                cmdTel.ExecuteNonQuery()
                            End Using
                        End If

                        tran.Commit()
                        postulante.EntidadID = entidadId
                        Return entidadId
                    Catch ex As Exception
                        tran.Rollback()
                        Throw New ApplicationException($"Error al registrar la persona y postulante: {ex.Message}", ex)
                    End Try
                End Using
            End Using
        End Function

        Public Function RegistrarExpedienteCompleto(expediente As ExpedienteColegiaturaBE, titulo As TituloProfesionalBE, documentos As List(Of DocumentoExpedienteBE)) As Integer Implements IExpedienteColegiaturaAccesoDatos.RegistrarExpedienteCompleto
            Using cnn As SqlConnection = SqlHelper.ObtenerConexion()
                cnn.Open()
                Using tran As SqlTransaction = cnn.BeginTransaction()
                    Try
                        ' 1. Insertar [Colegiatura].[ExpedienteColegiatura]
                        Const sqlExpediente As String = "INSERT INTO [Colegiatura].[ExpedienteColegiatura] " &
                                                        "([EntidadID], [NumeroExpediente], [FechaPresentacion], [EstadoRevision], [ValidadoSunedu], [ValidadoReniec], [AprobadoConsejo], [Observaciones]) " &
                                                        "VALUES (@EntidadID, @NumeroExpediente, GETDATE(), 'EN_REVISION', 0, 0, 0, @Observaciones); " &
                                                        "SELECT SCOPE_IDENTITY();"
                        Dim expedienteId As Integer
                        Using cmdExp As New SqlCommand(sqlExpediente, cnn, tran)
                            cmdExp.Parameters.Add(SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, expediente.EntidadID))
                            cmdExp.Parameters.Add(SqlHelper.CrearParametro("@NumeroExpediente", SqlDbType.Char, expediente.NumeroExpediente))
                            cmdExp.Parameters.Add(SqlHelper.CrearParametro("@Observaciones", SqlDbType.NVarChar, expediente.Observaciones, True))
                            expedienteId = Convert.ToInt32(cmdExp.ExecuteScalar())
                        End Using

                        ' 2. Insertar [Colegiatura].[TituloProfesional]
                        Const sqlTitulo As String = "INSERT INTO [Colegiatura].[TituloProfesional] " &
                                                    "([EntidadID], [UniversidadOrigen], [DenominacionTitulo], [FechaExpedicion], [CodigoRegistroSunedu], [VerificadoConSunedu]) " &
                                                    "VALUES (@EntidadID, @UniversidadOrigen, @DenominacionTitulo, @FechaExpedicion, @CodigoRegistroSunedu, 0);"
                        Using cmdTitulo As New SqlCommand(sqlTitulo, cnn, tran)
                            cmdTitulo.Parameters.Add(SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, expediente.EntidadID))
                            cmdTitulo.Parameters.Add(SqlHelper.CrearParametro("@UniversidadOrigen", SqlDbType.NVarChar, titulo.UniversidadOrigen))
                            cmdTitulo.Parameters.Add(SqlHelper.CrearParametro("@DenominacionTitulo", SqlDbType.NVarChar, titulo.DenominacionTitulo))
                            cmdTitulo.Parameters.Add(SqlHelper.CrearParametro("@FechaExpedicion", SqlDbType.Date, titulo.FechaExpedicion))
                            cmdTitulo.Parameters.Add(SqlHelper.CrearParametro("@CodigoRegistroSunedu", SqlDbType.NVarChar, titulo.CodigoRegistroSunedu))
                            cmdTitulo.ExecuteNonQuery()
                        End Using

                        ' 3. Insertar [Tramite].[DocumentoAdjunto] para cada archivo requerido
                        If documentos IsNot Nothing AndAlso documentos.Count > 0 Then
                            Const sqlDoc As String = "INSERT INTO [Tramite].[DocumentoAdjunto] " &
                                                     "([ExpedienteID], [NombreArchivo], [Extension], [RutaAlmacenamiento], [HashSHA256], [TamanoBytes], [TipoMime], [FechaCarga]) " &
                                                     "VALUES (@ExpedienteID, @NombreArchivo, @Extension, @RutaAlmacenamiento, @HashSHA256, @TamanoBytes, @TipoMime, GETDATE());"
                            For Each doc In documentos
                                Using cmdDoc As New SqlCommand(sqlDoc, cnn, tran)
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@ExpedienteID", SqlDbType.Int, expedienteId))
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@NombreArchivo", SqlDbType.NVarChar, doc.NombreArchivo))
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@Extension", SqlDbType.NVarChar, doc.Extension))
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@RutaAlmacenamiento", SqlDbType.NVarChar, doc.RutaAlmacenamiento))
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@HashSHA256", SqlDbType.Char, doc.HashSHA256))
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@TamanoBytes", SqlDbType.BigInt, doc.TamanoBytes))
                                    cmdDoc.Parameters.Add(SqlHelper.CrearParametro("@TipoMime", SqlDbType.NVarChar, doc.TipoMime))
                                    cmdDoc.ExecuteNonQuery()
                                End Using
                            Next
                        End If

                        tran.Commit()
                        expediente.ExpedienteColegiaturaID = expedienteId
                        Return expedienteId
                    Catch ex As Exception
                        tran.Rollback()
                        Throw New ApplicationException($"Error al registrar el expediente completo de colegiatura: {ex.Message}", ex)
                    End Try
                End Using
            End Using
        End Function

        Public Function ObtenerExpedientePorId(expedienteId As Integer) As ExpedienteColegiaturaBE Implements IExpedienteColegiaturaAccesoDatos.ObtenerExpedientePorId
            Const query As String = "SELECT [ExpedienteColegiaturaID], [EntidadID], [NumeroExpediente], [FechaPresentacion], " &
                                    "[EstadoRevision], [ValidadoSunedu], [ValidadoReniec], [AprobadoConsejo], [Observaciones], [ModifiedDate] " &
                                    "FROM [Colegiatura].[ExpedienteColegiatura] " &
                                    "WHERE [ExpedienteColegiaturaID] = @ExpedienteID"
            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@ExpedienteID", SqlDbType.Int, expedienteId)
            }
            Dim dt As DataTable = SqlHelper.ExecuteDataTable(query, parametros)
            If dt.Rows.Count = 0 Then Return Nothing

            Dim row As DataRow = dt.Rows(0)
            Return MapearExpedienteDesdeRow(row)
        End Function

        Public Function ObtenerExpedientePorNumero(numeroExpediente As String) As ExpedienteColegiaturaBE Implements IExpedienteColegiaturaAccesoDatos.ObtenerExpedientePorNumero
            Const query As String = "SELECT [ExpedienteColegiaturaID], [EntidadID], [NumeroExpediente], [FechaPresentacion], " &
                                    "[EstadoRevision], [ValidadoSunedu], [ValidadoReniec], [AprobadoConsejo], [Observaciones], [ModifiedDate] " &
                                    "FROM [Colegiatura].[ExpedienteColegiatura] " &
                                    "WHERE [NumeroExpediente] = @NumeroExpediente"
            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@NumeroExpediente", SqlDbType.Char, numeroExpediente.Trim())
            }
            Dim dt As DataTable = SqlHelper.ExecuteDataTable(query, parametros)
            If dt.Rows.Count = 0 Then Return Nothing

            Dim row As DataRow = dt.Rows(0)
            Return MapearExpedienteDesdeRow(row)
        End Function

        Public Function ListarDocumentosPorExpedienteId(expedienteId As Integer) As List(Of DocumentoExpedienteBE) Implements IExpedienteColegiaturaAccesoDatos.ListarDocumentosPorExpedienteId
            Const query As String = "SELECT [DocumentoAdjuntoID], [ExpedienteID], [NombreArchivo], [Extension], " &
                                    "[RutaAlmacenamiento], [HashSHA256], [TamanoBytes], [TipoMime], [FechaCarga] " &
                                    "FROM [Tramite].[DocumentoAdjunto] " &
                                    "WHERE [ExpedienteID] = @ExpedienteID"
            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@ExpedienteID", SqlDbType.Int, expedienteId)
            }
            Dim dt As DataTable = SqlHelper.ExecuteDataTable(query, parametros)
            Dim lista As New List(Of DocumentoExpedienteBE)()
            For Each row As DataRow In dt.Rows
                lista.Add(New DocumentoExpedienteBE With {
                    .DocumentoAdjuntoID = Convert.ToInt64(row("DocumentoAdjuntoID")),
                    .ExpedienteID = Convert.ToInt32(row("ExpedienteID")),
                    .NombreArchivo = row("NombreArchivo").ToString(),
                    .Extension = row("Extension").ToString(),
                    .RutaAlmacenamiento = row("RutaAlmacenamiento").ToString(),
                    .HashSHA256 = row("HashSHA256").ToString(),
                    .TamanoBytes = Convert.ToInt64(row("TamanoBytes")),
                    .TipoMime = row("TipoMime").ToString(),
                    .FechaCarga = Convert.ToDateTime(row("FechaCarga"))
                })
            Next
            Return lista
        End Function

        Private Shared Function MapearExpedienteDesdeRow(row As DataRow) As ExpedienteColegiaturaBE
            Return New ExpedienteColegiaturaBE With {
                .ExpedienteColegiaturaID = Convert.ToInt32(row("ExpedienteColegiaturaID")),
                .EntidadID = Convert.ToInt32(row("EntidadID")),
                .NumeroExpediente = row("NumeroExpediente").ToString().Trim(),
                .FechaPresentacion = Convert.ToDateTime(row("FechaPresentacion")),
                .EstadoRevision = row("EstadoRevision").ToString().Trim(),
                .ValidadoSunedu = Convert.ToBoolean(row("ValidadoSunedu")),
                .ValidadoReniec = Convert.ToBoolean(row("ValidadoReniec")),
                .AprobadoConsejo = Convert.ToBoolean(row("AprobadoConsejo")),
                .Observaciones = If(IsDBNull(row("Observaciones")), Nothing, row("Observaciones").ToString()),
                .ModifiedDate = Convert.ToDateTime(row("ModifiedDate"))
            }
        End Function
    End Class
End Namespace
