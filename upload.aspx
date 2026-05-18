<%@ Page Language="VB" %>

<%
If Request("reset") = "1" Then
	Session.Clear()
	Response.Redirect(Request.RawUrl)
End If
%>

<script runat="server">
	Function GetSuggestedMapping(attrs As List(Of String), target As String) As String

		Dim lowerAttrs = attrs.Select(Function(a) a.ToLower()).ToList()

		Select Case target.ToLower()

			Case "sn"
				If lowerAttrs.Contains("sn") Then Return "sn"

			Case "givenname"
				If lowerAttrs.Contains("givenname") Then Return "givenName"

			Case "employeenumber"
				If lowerAttrs.Contains("employeenumber") Then Return "employeeNumber"
				If lowerAttrs.Contains("employeeid") Then Return "employeeID"

			Case "telephonenumber"
				If lowerAttrs.Contains("telephonenumber") Then Return "telephoneNumber"

			Case "o"
				If lowerAttrs.Contains("o") Then Return "o"
				If lowerAttrs.Contains("organization") Then Return "organization"

		End Select

		' Default: erstes Attribut
		Return attrs(0)

	End Function
	
    Function GetAttributes(content As String) As List(Of String)

        Dim attrs As New List(Of String)
        Dim lines() As String = content.Split({vbCrLf}, StringSplitOptions.None)

        For Each line As String In lines

            If line.Contains(":") Then

                Dim key As String = line.Split(":"c)(0).Trim()

                If key <> "" AndAlso key <> "dn" AndAlso key <> "objectClass" Then
                    If Not attrs.Contains(key) Then
                        attrs.Add(key)
                    End If
                End If

            End If

        Next

        Return attrs

    End Function

</script>

<!DOCTYPE html>
<html>
<head>
    <title>LDIF Mapping Tool</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .box { border: 1px solid #ccc; padding: 20px; width: 600px; border-radius: 8px; }
        .success { color: green; }
        .error { color: red; }
        select { width: 100%; margin-bottom: 10px; }
    </style>
</head>
<body>

<div class="box">

<h2>LDIF Upload & Mapping</h2>

<form method="post" style="margin-bottom:20px;">
    <input type="hidden" name="reset" value="1" />
    <input type="submit" value="Reset" />
</form>

<%
Dim showMapping As Boolean = False
Dim errorMsg As String = ""

If Request.HttpMethod = "POST" AndAlso Request("step") = "" Then

    Dim file = Request.Files("fileUpload")

    If file IsNot Nothing AndAlso file.ContentLength > 0 Then

        Dim reader As New System.IO.StreamReader(file.InputStream)
        Dim content As String = reader.ReadToEnd()
        reader.Close()

        Session("ldifContent") = content

        Dim attributeList As List(Of String) = GetAttributes(content)
        Session("attributes") = attributeList

        showMapping = True

    Else
        errorMsg = "Keine Datei ausgewählt!"
    End If

End If
%>

<% If errorMsg <> "" Then %>
    <div class="error"><%= errorMsg %></div>
<% End If %>


<% If showMapping Then %>

<%
Dim attributeList As List(Of String) = CType(Session("attributes"), List(Of String))
%>

<h3>Mapping festlegen</h3>

<form method="post">
    <input type="hidden" name="step" value="map" />

    
	<%
	Dim suggested_sn As String = GetSuggestedMapping(attributeList, "sn")
	%>
	
	sn - surname / Nachname:
	<select name="sn">
		<% For Each a In attributeList %>
			<option value="<%= a %>" <% If a = suggested_sn Then %>selected<% End If %>>
				<%= a %>
			</option>
		<% Next %>
	</select>


    givenName - given Name / Vorname:
	<%
	Dim suggested_given As String = GetSuggestedMapping(attributeList, "givenName")
	%>

	<select name="givenName">
		<% For Each a In attributeList %>
			<option value="<%= a %>" <% If a = suggested_given Then %>selected<% End If %>>
				<%= a %>
			</option>
		<% Next %>
	</select>


    employeeNumber - employee ID / Mitarbeiter ID:
	<%
	Dim suggested_emp As String = GetSuggestedMapping(attributeList, "employeeNumber")
	%>

	<select name="employeeNumber">
		<% For Each a In attributeList %>
			<option value="<%= a %>" <% If a = suggested_emp Then %>selected<% End If %>>
				<%= a %>
			</option>
		<% Next %>
	</select>

    telephoneNumber - telephone number / Telefonnummer:
	<%
	Dim suggested_tel As String = GetSuggestedMapping(attributeList, "telephoneNumber")
	%>

	<select name="telephoneNumber">
		<option value="NA" <% If suggested_tel = "" Then %>selected<% End If %>>N/A</option>

		<% For Each a In attributeList %>
			<option value="<%= a %>" <% If a = suggested_tel Then %>selected<% End If %>>
				<%= a %>
			</option>
		<% Next %>
	</select>


    o - Organization ID / Organisations ID:
	<%
	Dim suggested_o As String = GetSuggestedMapping(attributeList, "o")
	%>

	<select name="o">
		<option value="NA" <% If suggested_o = "" Then %>selected<% End If %>>N/A</option>

		<% For Each a In attributeList %>
			<option value="<%= a %>" <% If a = suggested_o Then %>selected<% End If %>>
				<%= a %>
			</option>
		<% Next %>
	</select>

    <br /><br />
    <input type="submit" value="Konvertieren" />
</form>

<% ElseIf Request("step") = "map" Then %>

<%
Dim content As String = CType(Session("ldifContent"), String)

Dim map_sn = Request("sn")
Dim map_given = Request("givenName")
Dim map_emp = Request("employeeNumber")
Dim map_tel = Request("telephoneNumber")
Dim map_o = Request("o")

Dim entries() As String = content.Split(New String() {vbCrLf & vbCrLf}, StringSplitOptions.RemoveEmptyEntries)

Dim output As New System.Text.StringBuilder()

' OU Struktur falls benötigt
' output.AppendLine("dn: OU=Benutzer,DC=yourDomain,DC=com")
' output.AppendLine("changetype: add")
' output.AppendLine("objectClass: organizationalUnit")
' output.AppendLine("ou: Benutzer")
' output.AppendLine()

' output.AppendLine("dn: OU=Intern,OU=Benutzer,DC=yourDomain,DC=com")
' output.AppendLine("changetype: add")
' output.AppendLine("objectClass: organizationalUnit")
' output.AppendLine("ou: Intern")
' output.AppendLine()

' output.AppendLine("dn: OU=Extern,OU=Benutzer,DC=yourDomain,DC=com")
' output.AppendLine("changetype: add")
' output.AppendLine("objectClass: organizationalUnit")
' output.AppendLine("ou: Extern")
' output.AppendLine()

For Each entry In entries

    If entry.ToLower().Contains("objectclass: inetorgperson") Or entry.ToLower().Contains("objectclass: person") Then

        Dim values As New Dictionary(Of String, String)
        Dim lines() As String = entry.Split({vbCrLf}, StringSplitOptions.None)

        For Each line As String In lines
            If line.Contains(":") Then
                Dim parts = line.Split(":"c)
                values(parts(0).Trim()) = parts(1).Trim()
            End If
        Next

        Dim sn = If(values.ContainsKey(map_sn), values(map_sn), "")
        Dim givenName = If(values.ContainsKey(map_given), values(map_given), "")
        Dim emp = If(values.ContainsKey(map_emp), values(map_emp), "")
        Dim tel = If(values.ContainsKey(map_tel), values(map_tel), "")
        Dim org = If(values.ContainsKey(map_o), values(map_o), "")

        If sn <> "" AndAlso givenName <> "" Then

            Dim cn = givenName & " " & sn
            output.AppendLine("dn: CN=" & cn & ",OU=Users," & org & ",OU=organizations,DC=ccis,DC=deu")
            output.AppendLine("changetype: add")
            output.AppendLine("objectClass: inetOrgPerson")
            output.AppendLine("cn: " & cn)
            output.AppendLine("sn: " & sn)
            output.AppendLine("givenName: " & givenName)
            output.AppendLine("employeeNumber: " & emp)
            output.AppendLine("telephoneNumber: " & tel)
            output.AppendLine("o: " & org)
            output.AppendLine()
        End If

    End If

Next

Dim newFile As String = "import.ldif"
Dim path As String = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\NPO_LDIF-Import\" & newFile
System.IO.File.WriteAllText(path, output.ToString(), System.Text.Encoding.UTF8)

%>

<div class="success">
    Konvertierung fertig: <b><%= newFile %></b>
</div>

<% Else %>

<form method="post" enctype="multipart/form-data">
    <input type="file" name="fileUpload" accept=".ldif" required />
    <br /><br />
    <input type="submit" value="Upload" />
</form>

<% End If %>

</div>
</body>
</html>