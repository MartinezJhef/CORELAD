Imports System
Imports System.Collections.Generic
Imports System.Data
Imports Microsoft.Data.SqlClient
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports Helper.AccesoDatos

Namespace CLI.AccesoDatos
    ''' <summary>
    ''' Implementación ADO.NET parametrizada para la calificación y consulta de expedientes de colegiatura.
    ''' </summary>
    Public Class CalificacionColegiaturaAccesoDatos
        Implements ICalificacionColegiaturaAccesoDatos

        Public Sub New()
        End Sub

        Public Sub New(cadenaConexion As String)
            SqlHelper.CadenaConexion = cadenaConexion
        End Sub

        Public Function ListarExpedientesPendientes() As List(Of ExpedientePendienteDTO) Implements ICalificacionColegiaturaAccesoDatos.ListarExpedientesPendientes
            Dim lista As New List(Of ExpedientePendienteDTO)()

            ' Consulta parametrizada sobre ExpedienteColegiatura, Persona y TituloProfesional
            Dim sql = "SELECT e.ExpedienteColegiaturaID, e.NumeroExpediente, p.Dni, " &
                      "       (p.ApellidoPaterno + ' ' + p.ApellidoMaterno + ', ' + p.Nombres) AS NombrePostulante, " &
                      "       ISNULL(t.UniversidadOrigen, '') AS Universidad, " &
                      "       ISNULL(t.DenominacionTitulo, 'LICENCIADO EN ADMINISTRACION') AS TituloProfesional, " &
                      "       ISNULL(t.CodigoRegistroSunedu, '') AS CodigoRegistroSunedu, " &
                      "       e.FechaPresentacion, e.EstadoRevision, e.ValidadoSunedu, " &
                      "       (SELECT COUNT(1) FROM [Tramite].[DocumentoAdjunto] d WHERE d.ExpedienteID = e.ExpedienteColegiaturaID) AS TotalDocumentos " &
                      "FROM [Colegiatura].[ExpedienteColegiatura] e " &
                      "INNER JOIN [Persona].[Persona] p ON e.EntidadID = p.EntidadID " &
                      "LEFT JOIN [Colegiatura].[TituloProfesional] t ON e.EntidadID = t.EntidadID " &
                      "WHERE e.EstadoRevision IN ('EN_REVISION', 'ENVIADO', 'EST-ENV', 'EST-REV') " &
                      "ORDER BY e.FechaPresentacion ASC;"

            Dim dt As DataTable = SqlHelper.ExecuteDataTable(sql)

            For Each row As DataRow In dt.Rows
                Dim dto As New ExpedientePendienteDTO With {
                    .ExpedienteId = Convert.ToInt32(row("ExpedienteColegiaturaID")),
                    .NumeroExpediente = Convert.ToString(row("NumeroExpediente")),
                    .DniPostulante = Convert.ToString(row("Dni")),
                    .NombrePostulante = Convert.ToString(row("NombrePostulante")),
                    .Universidad = Convert.ToString(row("Universidad")),
                    .TituloProfesional = Convert.ToString(row("TituloProfesional")),
                    .CodigoRegistroSunedu = Convert.ToString(row("CodigoRegistroSunedu")),
                    .FechaPresentacion = Convert.ToDateTime(row("FechaPresentacion")),
                    .EstadoRevision = Convert.ToString(row("EstadoRevision")),
                    .ValidadoSunedu = If(IsDBNull(row("ValidadoSunedu")), False, Convert.ToBoolean(row("ValidadoSunedu"))),
                    .TotalDocumentos = Convert.ToInt32(row("TotalDocumentos"))
                }
                lista.Add(dto)
            Next

            Return lista
        End Function

        Public Function ObtenerDetalleExpediente(expedienteId As Integer) As ExpedienteDetalleAuditoriaDTO Implements ICalificacionColegiaturaAccesoDatos.ObtenerDetalleExpediente
            Dim sql = "SELECT e.ExpedienteColegiaturaID, e.NumeroExpediente, e.EntidadID, p.Dni, " &
                      "       (p.ApellidoPaterno + ' ' + p.ApellidoMaterno + ', ' + p.Nombres) AS NombrePostulante, " &
                      "       c.ValorContacto AS CorreoElectronico, " &
                      "       ct.ValorContacto AS Telefono, " &
                      "       ISNULL(d.DireccionDetalle, '') AS Direccion, " &
                      "       ISNULL(t.UniversidadOrigen, '') AS Universidad, " &
                      "       ISNULL(t.DenominacionTitulo, '') AS DenominacionTitulo, " &
                      "       ISNULL(t.CodigoRegistroSunedu, '') AS CodigoRegistroSunedu, " &
                      "       ISNULL(t.FechaExpedicion, '1900-01-01') AS FechaExpedicionTitulo, " &
                      "       e.FechaPresentacion, e.EstadoRevision, e.ValidadoSunedu " &
                      "FROM [Colegiatura].[ExpedienteColegiatura] e " &
                      "INNER JOIN [Persona].[Persona] p ON e.EntidadID = p.EntidadID " &
                      "LEFT JOIN [Persona].[Contacto] c ON p.EntidadID = c.EntidadID AND c.TipoContacto = 'EMAIL' " &
                      "LEFT JOIN [Persona].[Contacto] ct ON p.EntidadID = ct.EntidadID AND ct.TipoContacto = 'TELEFONO' " &
                      "LEFT JOIN [Persona].[Direccion] d ON p.EntidadID = d.EntidadID " &
                      "LEFT JOIN [Colegiatura].[TituloProfesional] t ON e.EntidadID = t.EntidadID " &
                      "WHERE e.ExpedienteColegiaturaID = @ExpedienteId;"

            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
            }
            Dim dt As DataTable = SqlHelper.ExecuteDataTable(sql, parametros)

            If dt.Rows.Count = 0 Then Return Nothing

            Dim row = dt.Rows(0)
            Dim detalle As New ExpedienteDetalleAuditoriaDTO With {
                .ExpedienteId = Convert.ToInt32(row("ExpedienteColegiaturaID")),
                .NumeroExpediente = Convert.ToString(row("NumeroExpediente")),
                .DniPostulante = Convert.ToString(row("Dni")),
                .NombrePostulante = Convert.ToString(row("NombrePostulante")),
                .CorreoElectronico = If(IsDBNull(row("CorreoElectronico")), "", Convert.ToString(row("CorreoElectronico"))),
                .Telefono = If(IsDBNull(row("Telefono")), "", Convert.ToString(row("Telefono"))),
                .Direccion = Convert.ToString(row("Direccion")),
                .Universidad = Convert.ToString(row("Universidad")),
                .DenominacionTitulo = Convert.ToString(row("DenominacionTitulo")),
                .NumeroResolucionTitulo = "",
                .FechaExpedicionTitulo = Convert.ToDateTime(row("FechaExpedicionTitulo")),
                .CodigoRegistroSunedu = Convert.ToString(row("CodigoRegistroSunedu")),
                .FechaPresentacion = Convert.ToDateTime(row("FechaPresentacion")),
                .EstadoRevision = Convert.ToString(row("EstadoRevision")),
                .ValidadoSunedu = If(IsDBNull(row("ValidadoSunedu")), False, Convert.ToBoolean(row("ValidadoSunedu")))
            }

            ' Obtener Documentos Digitalizados
            Dim sqlDocs = "SELECT DocumentoAdjuntoID, ExpedienteID, NombreArchivo, Extension, RutaAlmacenamiento, HashSHA256, TamanoBytes, TipoMime " &
                          "FROM [Tramite].[DocumentoAdjunto] " &
                          "WHERE ExpedienteID = @ExpedienteId;"

            Dim dtDocs As DataTable = SqlHelper.ExecuteDataTable(sqlDocs, parametros)

            For Each dRow As DataRow In dtDocs.Rows
                Dim docBE As New DocumentoExpedienteBE With {
                    .DocumentoAdjuntoID = Convert.ToInt64(dRow("DocumentoAdjuntoID")),
                    .ExpedienteID = expedienteId,
                    .NombreArchivo = Convert.ToString(dRow("NombreArchivo")),
                    .Extension = Convert.ToString(dRow("Extension")),
                    .RutaAlmacenamiento = Convert.ToString(dRow("RutaAlmacenamiento")),
                    .HashSHA256 = If(IsDBNull(dRow("HashSHA256")), "", Convert.ToString(dRow("HashSHA256"))),
                    .TamanoBytes = Convert.ToInt64(dRow("TamanoBytes")),
                    .TipoMime = If(IsDBNull(dRow("TipoMime")), "application/pdf", Convert.ToString(dRow("TipoMime"))),
                    .TipoDocumentoRequisito = "REQUISITO"
                }
                detalle.Documentos.Add(docBE)
            Next

            Return detalle
        End Function

        Public Function ActualizarDictamenExpediente(expedienteId As Integer, nuevoEstado As String, validadoSunedu As Boolean, observaciones As String, usuarioAuditor As String) As Boolean Implements ICalificacionColegiaturaAccesoDatos.ActualizarDictamenExpediente
            Dim sql = "UPDATE [Colegiatura].[ExpedienteColegiatura] " &
                      "SET EstadoRevision = @NuevoEstado, " &
                      "    ValidadoSunedu = @ValidadoSunedu, " &
                      "    Observaciones = @Observaciones, " &
                      "    ModifiedDate = GETDATE() " &
                      "WHERE ExpedienteColegiaturaID = @ExpedienteId;"

            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@NuevoEstado", SqlDbType.NVarChar, nuevoEstado),
                SqlHelper.CrearParametro("@ValidadoSunedu", SqlDbType.Bit, validadoSunedu),
                SqlHelper.CrearParametro("@Observaciones", SqlDbType.NVarChar, observaciones, True),
                SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
            }

            Dim filas = SqlHelper.ExecuteNonQuery(sql, parametros)
            Return filas > 0
        End Function

        Public Function ActualizarVerificacionTituloSunedu(expedienteId As Integer, codigoSunedu As String, verificado As Boolean, fechaVerificacion As Date) As Boolean Implements ICalificacionColegiaturaAccesoDatos.ActualizarVerificacionTituloSunedu
            Dim sql = "UPDATE t " &
                      "SET t.VerificadoConSunedu = @Verificado, " &
                      "    t.CodigoRegistroSunedu = @CodigoSunedu " &
                      "FROM [Colegiatura].[TituloProfesional] t " &
                      "INNER JOIN [Colegiatura].[ExpedienteColegiatura] e ON t.EntidadID = e.EntidadID " &
                      "WHERE e.ExpedienteColegiaturaID = @ExpedienteId;"

            Dim parametros As New List(Of SqlParameter) From {
                SqlHelper.CrearParametro("@Verificado", SqlDbType.Bit, verificado),
                SqlHelper.CrearParametro("@CodigoSunedu", SqlDbType.NVarChar, codigoSunedu),
                SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
            }

            Dim filas = SqlHelper.ExecuteNonQuery(sql, parametros)
            Return filas > 0
        End Function
    End Class
End Namespace
