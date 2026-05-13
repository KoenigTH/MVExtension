<%@ Page Language="VB" %>

<!DOCTYPE html>
<html>
<head>
    <title>LDIF Upload</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .box { border: 1px solid #ccc; padding: 20px; width: 400px; border-radius: 8px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>

<div class="box">
    <h2>LDIF Datei hochladen</h2>

    <form method="post" enctype="multipart/form-data">
        <input type="file" name="fileUpload" accept=".ldif" required />
        <br /><br />
        <input type="submit" value="Upload" />
    </form>

    <br />

    <%
        If Request.HttpMethod = "POST" Then
            Try
                Dim file = Request.Files("fileUpload")

                If file IsNot Nothing AndAlso file.ContentLength > 0 Then
                    Dim extension As String = System.IO.Path.GetExtension(file.FileName).ToLower()

                    ' Nur LDIF erlauben
                    If extension <> ".ldif" Then
                        Response.Write("<div class='error'>Nur .ldif Dateien erlaubt!</div>")
                    Else
                        ' Zielverzeichnis = aktuelles Verzeichnis der Seite
                        Dim savePath As String = Server.MapPath(".") & "\" & System.IO.Path.GetFileName(file.FileName)

                        file.SaveAs(savePath)

                        Response.Write("<div class='success'>Upload erfolgreich: " & file.FileName & "</div>")
                    End If
                Else
                    Response.Write("<div class='error'>Keine Datei ausgewählt!</div>")
                End If
            Catch ex As Exception
                Response.Write("<div class='error'>Fehler: " & ex.Message & "</div>")
            End Try
        End If
    %>

</div>

</body>
</html>