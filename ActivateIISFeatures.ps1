<#
.SYNOPSIS
Installiert IIS Webserver mit ASP.NET 4.x und notwendigen Komponenten.

.DESCRIPTION
Dieses Script installiert:
- Internet Information Services (IIS)
- Web Management Tools
- World Wide Web Services
- ASP.NET 4.x
- .NET Extensibility 4.x
- ISAPI Extensions und Filter

.NOTES
Script muss als Administrator gestartet werden.
#>

# Prüfen, ob das Script als Administrator ausgeführt wird
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "Dieses Script muss als Administrator ausgeführt werden."
    exit 1
}

Write-Host "Installation der IIS Features wird gestartet..."

# Liste der benötigten Windows Features
$features = @(
    "Web-App-Dev",          # Application Development Basis
    "Web-Asp-Net45",        # ASP.NET 4.x
    "Web-Net-Ext45",        # .NET Extensibility
    "Web-ISAPI-Ext",        # ISAPI Extensions
    "Web-ISAPI-Filter",     # ISAPI Filter
)

# Installation durchführen
try {
    Install-WindowsFeature -Name $features -IncludeManagementTools -ErrorAction Stop
    Write-Host "Installation wurde erfolgreich abgeschlossen."
}
catch {
    Write-Error "Fehler bei der Installation: $_"
    exit 1
}

# IIS Dienst prüfen
Write-Host "Prüfung des IIS Dienstes..."

$service = Get-Service -Name W3SVC -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq "Running") {
    Write-Host "IIS Dienst läuft."
} else {
    Write-Host "IIS Dienst wird gestartet..."
    Start-Service W3SVC
}

# Abschlussmeldung
Write-Host "Setup abgeschlossen."
Write-Host "Hinweis: Der Application Pool sollte auf .NET CLR Version v4 eingestellt sein."
