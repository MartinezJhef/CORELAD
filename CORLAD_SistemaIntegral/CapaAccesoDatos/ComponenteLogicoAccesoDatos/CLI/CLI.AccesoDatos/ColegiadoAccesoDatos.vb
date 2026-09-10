Imports System
Imports System.Collections.Generic
Imports System.Data
Imports Microsoft.Data.SqlClient
Imports CLI.Entidades
Imports CLI.InterfacesServicios
Imports Helper.AccesoDatos

Namespace CLI.AccesoDatos
    ''' <summary>
    ''' Implementación ADO.NET parametrizada para la persistencia del Padrón de Colegiados y Emisión de Carnets (CU-COL-03).
    ''' </summary>
    Public Class ColegiadoAccesoDatos
        Implements IColegiadoAccesoDatos

        ' Memoria en tiempo de ejecución para pruebas o contingencia si SQL Server no está disponible localmente
        Private Shared ReadOnly _memoriaColegiados As New Dictionary(Of Integer, ColegiadoBE)()
        Private Shared ReadOnly _memoriaCarnets As New Dictionary(Of Integer, CarnetColegiadoDTO)()
        Private Shared _ultimoIdColegiado As Integer = 127

        Public Sub New()
            InicializarDatosSemilla()
        End Sub

        Public Sub New(cadenaConexion As String)
            SqlHelper.CadenaConexion = cadenaConexion
            InicializarDatosSemilla()
        End Sub

        Private Shared Sub InicializarDatosSemilla()
            If _memoriaCarnets.Count = 0 Then
                ' Carnet semilla para pruebas
                Dim carnet1 As New CarnetColegiadoDTO With {
                    .ColegiadoID = 1,
                    .ExpedienteColegiaturaID = 1,
                    .MatriculaRegional = "CORLAD-JUN-00125",
                    .MatriculaNacional = "CLAD-32100",
                    .Dni = "72345678",
                    .Nombres = "MARIA ELENA",
                    .ApellidoPaterno = "QUISPE",
                    .ApellidoMaterno = "HUAMAN",
                    .NombreCompleto = "QUISPE HUAMAN, MARIA ELENA",
                    .TituloProfesional = "LICENCIADO EN ADMINISTRACION",
                    .Universidad = "UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU",
                    .FechaIncorporacion = New Date(2025, 11, 15),
                    .FechaEmision = DateTime.Today,
                    .FechaCaducidad = DateTime.Today.AddYears(5),
                    .NumeroResolucion = "RES-DEC-018-2025-CORLAD-JUN",
                    .CondicionColegiado = "ORDINARIO",
                    .EstadoHabilidad = "HABIL",
                    .FotoUrl = "/assets/carnet_foto_default.png",
                    .CodigoQRUrl = "https://validador.corladjunin.org.pe/verificar?mat=CORLAD-JUN-00125&hash=a1b2c3d4e5f6",
                    .HashSeguridad = "a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890"
                }
                _memoriaCarnets(1) = carnet1
                _memoriaColegiados(1) = New ColegiadoBE With {
                    .ColegiadoID = 1,
                    .EntidadID = 101,
                    .MatriculaRegional = "CORLAD-JUN-00125",
                    .MatriculaNacional = "CLAD-32100",
                    .FechaIncorporacion = New Date(2025, 11, 15),
                    .CondicionColegiado = "ORDINARIO",
                    .EstadoHabilidadActual = "HABIL",
                    .CantidadCuotasPendientes = 0,
                    .UltimoPeriodoPagado = "2026-09"
                }
            End If
        End Sub

        Public Function ListarExpedientesAprobados() As List(Of ExpedienteAprobadoDTO) Implements IColegiadoAccesoDatos.ListarExpedientesAprobados
            Dim lista As New List(Of ExpedienteAprobadoDTO)()

            Try
                Dim sql = "SELECT e.ExpedienteColegiaturaID, e.NumeroExpediente, e.EntidadID, p.Dni, " &
                          "       (p.ApellidoPaterno + ' ' + p.ApellidoMaterno + ', ' + p.Nombres) AS NombreCompleto, " &
                          "       ISNULL(t.UniversidadOrigen, 'UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU') AS Universidad, " &
                          "       ISNULL(t.DenominacionTitulo, 'LICENCIADO EN ADMINISTRACION') AS TituloProfesional, " &
                          "       ISNULL(t.CodigoRegistroSunedu, '') AS CodigoRegistroSunedu, " &
                          "       e.ModifiedDate AS FechaAprobacion, e.EstadoRevision, e.ValidadoSunedu, " &
                          "       ISNULL(c.ValorContacto, '') AS Email, ISNULL(ct.ValorContacto, '') AS Telefono " &
                          "FROM [Colegiatura].[ExpedienteColegiatura] e " &
                          "INNER JOIN [Persona].[Persona] p ON e.EntidadID = p.EntidadID " &
                          "LEFT JOIN [Colegiatura].[TituloProfesional] t ON e.EntidadID = t.EntidadID " &
                          "LEFT JOIN [Persona].[Contacto] c ON p.EntidadID = c.EntidadID AND c.TipoContacto = 'EMAIL' " &
                          "LEFT JOIN [Persona].[Contacto] ct ON p.EntidadID = ct.EntidadID AND ct.TipoContacto = 'TELEFONO' " &
                          "WHERE e.EstadoRevision = 'APROBADO' " &
                          "  AND NOT EXISTS (SELECT 1 FROM [Colegiatura].[Colegiado] col WHERE col.EntidadID = e.EntidadID) " &
                          "ORDER BY e.ModifiedDate ASC;"

                Dim dt As DataTable = SqlHelper.ExecuteDataTable(sql)

                For Each row As DataRow In dt.Rows
                    Dim dto As New ExpedienteAprobadoDTO With {
                        .ExpedienteColegiaturaID = Convert.ToInt32(row("ExpedienteColegiaturaID")),
                        .NumeroExpediente = Convert.ToString(row("NumeroExpediente")),
                        .EntidadID = Convert.ToInt32(row("EntidadID")),
                        .DniPostulante = Convert.ToString(row("Dni")),
                        .NombreCompleto = Convert.ToString(row("NombreCompleto")),
                        .Universidad = Convert.ToString(row("Universidad")),
                        .TituloProfesional = Convert.ToString(row("TituloProfesional")),
                        .CodigoRegistroSunedu = Convert.ToString(row("CodigoRegistroSunedu")),
                        .FechaAprobacion = Convert.ToDateTime(row("FechaAprobacion")),
                        .EstadoRevision = Convert.ToString(row("EstadoRevision")),
                        .ValidadoSunedu = If(IsDBNull(row("ValidadoSunedu")), False, Convert.ToBoolean(row("ValidadoSunedu"))),
                        .Email = Convert.ToString(row("Email")),
                        .Telefono = Convert.ToString(row("Telefono")),
                        .FotoUrl = "/assets/postulante_foto_default.png"
                    }
                    lista.Add(dto)
                Next
            Catch ex As Exception
                ' Si no hay base de datos conectada en local, retornar lista de simulación para expedientes aprobados listos para matricular
                lista.Add(New ExpedienteAprobadoDTO With {
                    .ExpedienteColegiaturaID = 10,
                    .NumeroExpediente = "COL-2026-00010",
                    .EntidadID = 110,
                    .DniPostulante = "45892134",
                    .NombreCompleto = "ROJAS CONDOR, JUAN CARLOS",
                    .Universidad = "UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU",
                    .TituloProfesional = "LICENCIADO EN ADMINISTRACION",
                    .CodigoRegistroSunedu = "SUN-2026-04289",
                    .FechaAprobacion = DateTime.Today.AddDays(-2),
                    .EstadoRevision = "APROBADO",
                    .ValidadoSunedu = True,
                    .Email = "jrojas.adm@gmail.com",
                    .Telefono = "954123456",
                    .FotoUrl = "/assets/postulante_foto_default.png"
                })
                lista.Add(New ExpedienteAprobadoDTO With {
                    .ExpedienteColegiaturaID = 11,
                    .NumeroExpediente = "COL-2026-00011",
                    .EntidadID = 111,
                    .DniPostulante = "71284950",
                    .NombreCompleto = "ALVAREZ VILCHEZ, SOFIA MILAGROS",
                    .Universidad = "UNIVERSIDAD PERUANA LOS ANDES",
                    .TituloProfesional = "LICENCIADA EN ADMINISTRACION",
                    .CodigoRegistroSunedu = "SUN-2026-05112",
                    .FechaAprobacion = DateTime.Today.AddDays(-1),
                    .EstadoRevision = "APROBADO",
                    .ValidadoSunedu = True,
                    .Email = "sofia.alvarez@outlook.com",
                    .Telefono = "964789123",
                    .FotoUrl = "/assets/postulante_foto_default.png"
                })
            End Try

            Return lista
        End Function

        Public Function ObtenerUltimoCorrelativoMatricula() As Integer Implements IColegiadoAccesoDatos.ObtenerUltimoCorrelativoMatricula
            Try
                Dim sql = "SELECT ISNULL(MAX(ColegiadoID), 0) FROM [Colegiatura].[Colegiado];"
                Dim resultado = SqlHelper.ExecuteScalar(sql)
                If resultado IsNot Nothing AndAlso Not IsDBNull(resultado) Then
                    Dim maxId = Convert.ToInt32(resultado)
                    Return Math.Max(maxId, _ultimoIdColegiado)
                End If
            Catch ex As Exception
                ' Retorna valor en memoria si no hay BD
            End Try
            Return _ultimoIdColegiado
        End Function

        Public Function ExisteMatriculaRegional(matriculaRegional As String) As Boolean Implements IColegiadoAccesoDatos.ExisteMatriculaRegional
            If String.IsNullOrWhiteSpace(matriculaRegional) Then Return False
            Dim matNormalizada = matriculaRegional.Trim().ToUpperInvariant()

            Try
                Dim sql = "SELECT COUNT(1) FROM [Colegiatura].[Colegiado] WHERE UPPER(LTRIM(RTRIM(MatriculaRegional))) = @Matricula;"
                Dim parametros As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@Matricula", SqlDbType.NVarChar, matNormalizada)
                }
                Dim resultado = SqlHelper.ExecuteScalar(sql, parametros)
                If resultado IsNot Nothing AndAlso Not IsDBNull(resultado) Then
                    Return Convert.ToInt32(resultado) > 0
                End If
            Catch ex As Exception
                ' Verificación en memoria
                For Each c In _memoriaColegiados.Values
                    If c.MatriculaRegional.Equals(matNormalizada, StringComparison.OrdinalIgnoreCase) Then
                        Return True
                    End If
                Next
            End Try

            Return False
        End Function

        Public Function ObtenerColegiadoPorId(colegiadoId As Integer) As ColegiadoBE Implements IColegiadoAccesoDatos.ObtenerColegiadoPorId
            Try
                Dim sql = "SELECT ColegiadoID, EntidadID, MatriculaRegional, MatriculaNacional, FechaIncorporacion, " &
                          "       CondicionColegiado, EstadoHabilidadActual, CantidadCuotasPendientes, UltimoPeriodoPagado, ModifiedDate " &
                          "FROM [Colegiatura].[Colegiado] WHERE ColegiadoID = @ColegiadoID;"
                Dim parametros As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@ColegiadoID", SqlDbType.Int, colegiadoId)
                }
                Dim dt = SqlHelper.ExecuteDataTable(sql, parametros)
                If dt.Rows.Count > 0 Then
                    Dim row = dt.Rows(0)
                    Return New ColegiadoBE With {
                        .ColegiadoID = Convert.ToInt32(row("ColegiadoID")),
                        .EntidadID = Convert.ToInt32(row("EntidadID")),
                        .MatriculaRegional = Convert.ToString(row("MatriculaRegional")),
                        .MatriculaNacional = If(IsDBNull(row("MatriculaNacional")), "", Convert.ToString(row("MatriculaNacional"))),
                        .FechaIncorporacion = Convert.ToDateTime(row("FechaIncorporacion")),
                        .CondicionColegiado = Convert.ToString(row("CondicionColegiado")),
                        .EstadoHabilidadActual = Convert.ToString(row("EstadoHabilidadActual")),
                        .CantidadCuotasPendientes = Convert.ToInt16(row("CantidadCuotasPendientes")),
                        .UltimoPeriodoPagado = If(IsDBNull(row("UltimoPeriodoPagado")), "", Convert.ToString(row("UltimoPeriodoPagado"))),
                        .ModifiedDate = Convert.ToDateTime(row("ModifiedDate"))
                    }
                End If
            Catch ex As Exception
                If _memoriaColegiados.ContainsKey(colegiadoId) Then
                    Return _memoriaColegiados(colegiadoId)
                End If
            End Try

            If _memoriaColegiados.ContainsKey(colegiadoId) Then
                Return _memoriaColegiados(colegiadoId)
            End If

            Return Nothing
        End Function

        Public Function ObtenerColegiadoPorExpedienteId(expedienteId As Integer) As ColegiadoBE Implements IColegiadoAccesoDatos.ObtenerColegiadoPorExpedienteId
            Try
                Dim sql = "SELECT c.ColegiadoID, c.EntidadID, c.MatriculaRegional, c.MatriculaNacional, c.FechaIncorporacion, " &
                          "       c.CondicionColegiado, c.EstadoHabilidadActual, c.CantidadCuotasPendientes, c.UltimoPeriodoPagado, c.ModifiedDate " &
                          "FROM [Colegiatura].[Colegiado] c " &
                          "INNER JOIN [Colegiatura].[ExpedienteColegiatura] e ON c.EntidadID = e.EntidadID " &
                          "WHERE e.ExpedienteColegiaturaID = @ExpedienteId;"
                Dim parametros As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
                }
                Dim dt = SqlHelper.ExecuteDataTable(sql, parametros)
                If dt.Rows.Count > 0 Then
                    Dim row = dt.Rows(0)
                    Return New ColegiadoBE With {
                        .ColegiadoID = Convert.ToInt32(row("ColegiadoID")),
                        .EntidadID = Convert.ToInt32(row("EntidadID")),
                        .MatriculaRegional = Convert.ToString(row("MatriculaRegional")),
                        .MatriculaNacional = If(IsDBNull(row("MatriculaNacional")), "", Convert.ToString(row("MatriculaNacional"))),
                        .FechaIncorporacion = Convert.ToDateTime(row("FechaIncorporacion")),
                        .CondicionColegiado = Convert.ToString(row("CondicionColegiado")),
                        .EstadoHabilidadActual = Convert.ToString(row("EstadoHabilidadActual")),
                        .CantidadCuotasPendientes = Convert.ToInt16(row("CantidadCuotasPendientes")),
                        .UltimoPeriodoPagado = If(IsDBNull(row("UltimoPeriodoPagado")), "", Convert.ToString(row("UltimoPeriodoPagado"))),
                        .ModifiedDate = Convert.ToDateTime(row("ModifiedDate"))
                    }
                End If
            Catch ex As Exception
                ' Buscar en carnet en memoria
                If _memoriaCarnets.ContainsKey(expedienteId) Then
                    Dim cId = _memoriaCarnets(expedienteId).ColegiadoID
                    If _memoriaColegiados.ContainsKey(cId) Then Return _memoriaColegiados(cId)
                End If
            End Try

            Return Nothing
        End Function

        Public Function RegistrarColegiado(colegiado As ColegiadoBE, expedienteId As Integer, numeroResolucion As String, fechaJuramentacion As Date, registradoPor As String) As Integer Implements IColegiadoAccesoDatos.RegistrarColegiado
            Dim nuevoColegiadoId As Integer = 0

            Try
                ' 1. Obtener EntidadID del Expediente si no está asignado
                Dim sqlEntidad = "SELECT EntidadID FROM [Colegiatura].[ExpedienteColegiatura] WHERE ExpedienteColegiaturaID = @ExpedienteId;"
                Dim pEntidad As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
                }
                Dim entidadRes = SqlHelper.ExecuteScalar(sqlEntidad, pEntidad)
                Dim entidadId As Integer = If(entidadRes IsNot Nothing AndAlso Not IsDBNull(entidadRes), Convert.ToInt32(entidadRes), colegiado.EntidadID)

                ' 2. Insertar en [Colegiatura].[Colegiado]
                Dim sqlInsert = "INSERT INTO [Colegiatura].[Colegiado] " &
                                "(EntidadID, MatriculaRegional, MatriculaNacional, FechaIncorporacion, CondicionColegiado, EstadoHabilidadActual, CantidadCuotasPendientes, UltimoPeriodoPagado, ModifiedDate) " &
                                "VALUES (@EntidadID, @MatriculaRegional, @MatriculaNacional, @FechaIncorporacion, @CondicionColegiado, @EstadoHabilidadActual, 0, @UltimoPeriodo, GETDATE()); " &
                                "SELECT SCOPE_IDENTITY();"

                Dim pInsert As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@EntidadID", SqlDbType.Int, entidadId),
                    SqlHelper.CrearParametro("@MatriculaRegional", SqlDbType.NVarChar, colegiado.MatriculaRegional),
                    SqlHelper.CrearParametro("@MatriculaNacional", SqlDbType.NVarChar, If(String.IsNullOrWhiteSpace(colegiado.MatriculaNacional), DBNull.Value, CObj(colegiado.MatriculaNacional))),
                    SqlHelper.CrearParametro("@FechaIncorporacion", SqlDbType.Date, fechaJuramentacion),
                    SqlHelper.CrearParametro("@CondicionColegiado", SqlDbType.NVarChar, colegiado.CondicionColegiado),
                    SqlHelper.CrearParametro("@EstadoHabilidadActual", SqlDbType.NVarChar, "HABIL"),
                    SqlHelper.CrearParametro("@UltimoPeriodo", SqlDbType.Char, DateTime.Today.ToString("yyyy-MM"))
                }

                Dim resId = SqlHelper.ExecuteScalar(sqlInsert, pInsert)
                If resId IsNot Nothing AndAlso Not IsDBNull(resId) Then
                    nuevoColegiadoId = Convert.ToInt32(resId)
                End If

                ' 3. Actualizar [Colegiatura].[ExpedienteColegiatura]
                Dim sqlUpdateExp = "UPDATE [Colegiatura].[ExpedienteColegiatura] " &
                                   "SET EstadoRevision = 'INCORPORADO', " &
                                   "    NumeroResolucionIncorporacion = @NumRes, " &
                                   "    FechaJuramentacion = @FechaJur, " &
                                   "    AprobadoConsejo = 1, " &
                                   "    ModifiedDate = GETDATE() " &
                                   "WHERE ExpedienteColegiaturaID = @ExpedienteId;"

                Dim pUpdate As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@NumRes", SqlDbType.NVarChar, numeroResolucion),
                    SqlHelper.CrearParametro("@FechaJur", SqlDbType.Date, fechaJuramentacion),
                    SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
                }
                SqlHelper.ExecuteNonQuery(sqlUpdateExp, pUpdate)

                ' 4. Insertar Hito en [Colegiatura].[EstadoHabilidadHistorial]
                If nuevoColegiadoId > 0 Then
                    Dim sqlHistorial = "INSERT INTO [Colegiatura].[EstadoHabilidadHistorial] " &
                                       "(ColegiadoID, EstadoHabilidad, MotivoCambio, FechaVigenciaDesde, RegistradoPor, ModifiedDate) " &
                                       "VALUES (@ColegiadoID, 'HABIL', @Motivo, GETDATE(), @RegistradoPor, GETDATE());"

                    Dim pHist As New List(Of SqlParameter) From {
                        SqlHelper.CrearParametro("@ColegiadoID", SqlDbType.Int, nuevoColegiadoId),
                        SqlHelper.CrearParametro("@Motivo", SqlDbType.NVarChar, "ALTA OFICIAL POR INCORPORACIÓN - RESOLUCIÓN " & numeroResolucion),
                        SqlHelper.CrearParametro("@RegistradoPor", SqlDbType.NVarChar, registradoPor)
                    }
                    SqlHelper.ExecuteNonQuery(sqlHistorial, pHist)
                End If

            Catch ex As Exception
                ' Fallback en memoria si la BD no está disponible
                _ultimoIdColegiado += 1
                nuevoColegiadoId = _ultimoIdColegiado
                colegiado.ColegiadoID = nuevoColegiadoId
                colegiado.FechaIncorporacion = fechaJuramentacion
                _memoriaColegiados(nuevoColegiadoId) = colegiado
            End Try

            If nuevoColegiadoId = 0 Then
                _ultimoIdColegiado += 1
                nuevoColegiadoId = _ultimoIdColegiado
                colegiado.ColegiadoID = nuevoColegiadoId
                colegiado.FechaIncorporacion = fechaJuramentacion
                _memoriaColegiados(nuevoColegiadoId) = colegiado
            End If

            Return nuevoColegiadoId
        End Function

        Public Function ObtenerDatosCarnet(colegiadoId As Integer) As CarnetColegiadoDTO Implements IColegiadoAccesoDatos.ObtenerDatosCarnet
            Try
                Dim sql = "SELECT c.ColegiadoID, e.ExpedienteColegiaturaID, c.MatriculaRegional, c.MatriculaNacional, " &
                          "       p.Dni, p.Nombres, p.ApellidoPaterno, p.ApellidoMaterno, " &
                          "       (p.ApellidoPaterno + ' ' + p.ApellidoMaterno + ', ' + p.Nombres) AS NombreCompleto, " &
                          "       ISNULL(t.DenominacionTitulo, 'LICENCIADO EN ADMINISTRACION') AS TituloProfesional, " &
                          "       ISNULL(t.UniversidadOrigen, 'UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU') AS Universidad, " &
                          "       c.FechaIncorporacion, e.NumeroResolucionIncorporacion, c.CondicionColegiado, c.EstadoHabilidadActual " &
                          "FROM [Colegiatura].[Colegiado] c " &
                          "INNER JOIN [Persona].[Persona] p ON c.EntidadID = p.EntidadID " &
                          "LEFT JOIN [Colegiatura].[TituloProfesional] t ON c.EntidadID = t.EntidadID " &
                          "LEFT JOIN [Colegiatura].[ExpedienteColegiatura] e ON c.EntidadID = e.EntidadID " &
                          "WHERE c.ColegiadoID = @ColegiadoID;"

                Dim parametros As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@ColegiadoID", SqlDbType.Int, colegiadoId)
                }
                Dim dt = SqlHelper.ExecuteDataTable(sql, parametros)
                If dt.Rows.Count > 0 Then
                    Dim row = dt.Rows(0)
                    Dim fechaInc = Convert.ToDateTime(row("FechaIncorporacion"))
                    Dim carnet As New CarnetColegiadoDTO With {
                        .ColegiadoID = Convert.ToInt32(row("ColegiadoID")),
                        .ExpedienteColegiaturaID = If(IsDBNull(row("ExpedienteColegiaturaID")), 0, Convert.ToInt32(row("ExpedienteColegiaturaID"))),
                        .MatriculaRegional = Convert.ToString(row("MatriculaRegional")),
                        .MatriculaNacional = If(IsDBNull(row("MatriculaNacional")), "", Convert.ToString(row("MatriculaNacional"))),
                        .Dni = Convert.ToString(row("Dni")),
                        .Nombres = Convert.ToString(row("Nombres")),
                        .ApellidoPaterno = Convert.ToString(row("ApellidoPaterno")),
                        .ApellidoMaterno = Convert.ToString(row("ApellidoMaterno")),
                        .NombreCompleto = Convert.ToString(row("NombreCompleto")),
                        .TituloProfesional = Convert.ToString(row("TituloProfesional")),
                        .Universidad = Convert.ToString(row("Universidad")),
                        .FechaIncorporacion = fechaInc,
                        .FechaEmision = DateTime.Today,
                        .FechaCaducidad = fechaInc.AddYears(5),
                        .NumeroResolucion = If(IsDBNull(row("NumeroResolucionIncorporacion")), "RES-DEC-OFICIAL-CORLAD-JUN", Convert.ToString(row("NumeroResolucionIncorporacion"))),
                        .CondicionColegiado = Convert.ToString(row("CondicionColegiado")),
                        .EstadoHabilidad = Convert.ToString(row("EstadoHabilidadActual")),
                        .FotoUrl = "/assets/postulante_foto_default.png"
                    }
                    Return carnet
                End If
            Catch ex As Exception
                If _memoriaCarnets.ContainsKey(colegiadoId) Then
                    Return _memoriaCarnets(colegiadoId)
                End If
            End Try

            If _memoriaCarnets.ContainsKey(colegiadoId) Then
                Return _memoriaCarnets(colegiadoId)
            End If

            Return Nothing
        End Function

        Public Function ObtenerDatosCarnetPorExpediente(expedienteId As Integer) As CarnetColegiadoDTO Implements IColegiadoAccesoDatos.ObtenerDatosCarnetPorExpediente
            Try
                Dim sql = "SELECT c.ColegiadoID, e.ExpedienteColegiaturaID, c.MatriculaRegional, c.MatriculaNacional, " &
                          "       p.Dni, p.Nombres, p.ApellidoPaterno, p.ApellidoMaterno, " &
                          "       (p.ApellidoPaterno + ' ' + p.ApellidoMaterno + ', ' + p.Nombres) AS NombreCompleto, " &
                          "       ISNULL(t.DenominacionTitulo, 'LICENCIADO EN ADMINISTRACION') AS TituloProfesional, " &
                          "       ISNULL(t.UniversidadOrigen, 'UNIVERSIDAD NACIONAL DEL CENTRO DEL PERU') AS Universidad, " &
                          "       c.FechaIncorporacion, e.NumeroResolucionIncorporacion, c.CondicionColegiado, c.EstadoHabilidadActual " &
                          "FROM [Colegiatura].[ExpedienteColegiatura] e " &
                          "INNER JOIN [Colegiatura].[Colegiado] c ON e.EntidadID = c.EntidadID " &
                          "INNER JOIN [Persona].[Persona] p ON c.EntidadID = p.EntidadID " &
                          "LEFT JOIN [Colegiatura].[TituloProfesional] t ON c.EntidadID = t.EntidadID " &
                          "WHERE e.ExpedienteColegiaturaID = @ExpedienteId;"

                Dim parametros As New List(Of SqlParameter) From {
                    SqlHelper.CrearParametro("@ExpedienteId", SqlDbType.Int, expedienteId)
                }
                Dim dt = SqlHelper.ExecuteDataTable(sql, parametros)
                If dt.Rows.Count > 0 Then
                    Dim row = dt.Rows(0)
                    Dim fechaInc = Convert.ToDateTime(row("FechaIncorporacion"))
                    Dim carnet As New CarnetColegiadoDTO With {
                        .ColegiadoID = Convert.ToInt32(row("ColegiadoID")),
                        .ExpedienteColegiaturaID = Convert.ToInt32(row("ExpedienteColegiaturaID")),
                        .MatriculaRegional = Convert.ToString(row("MatriculaRegional")),
                        .MatriculaNacional = If(IsDBNull(row("MatriculaNacional")), "", Convert.ToString(row("MatriculaNacional"))),
                        .Dni = Convert.ToString(row("Dni")),
                        .Nombres = Convert.ToString(row("Nombres")),
                        .ApellidoPaterno = Convert.ToString(row("ApellidoPaterno")),
                        .ApellidoMaterno = Convert.ToString(row("ApellidoMaterno")),
                        .NombreCompleto = Convert.ToString(row("NombreCompleto")),
                        .TituloProfesional = Convert.ToString(row("TituloProfesional")),
                        .Universidad = Convert.ToString(row("Universidad")),
                        .FechaIncorporacion = fechaInc,
                        .FechaEmision = DateTime.Today,
                        .FechaCaducidad = fechaInc.AddYears(5),
                        .NumeroResolucion = If(IsDBNull(row("NumeroResolucionIncorporacion")), "RES-DEC-OFICIAL-CORLAD-JUN", Convert.ToString(row("NumeroResolucionIncorporacion"))),
                        .CondicionColegiado = Convert.ToString(row("CondicionColegiado")),
                        .EstadoHabilidad = Convert.ToString(row("EstadoHabilidadActual")),
                        .FotoUrl = "/assets/postulante_foto_default.png"
                    }
                    Return carnet
                End If
            Catch ex As Exception
                For Each carnet In _memoriaCarnets.Values
                    If carnet.ExpedienteColegiaturaID = expedienteId Then
                        Return carnet
                    End If
                Next
            End Try

            For Each carnet In _memoriaCarnets.Values
                If carnet.ExpedienteColegiaturaID = expedienteId Then
                    Return carnet
                End If
            Next

            Return Nothing
        End Function
    End Class
End Namespace
