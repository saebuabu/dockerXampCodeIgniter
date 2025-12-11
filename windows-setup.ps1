# Windows 10 Development Stack Installation Script
# Voor CodeIgniter 4 met SQL Server
# Run dit script als Administrator in PowerShell

# Configuratie
$ProjectRoot = $PSScriptRoot
$DownloadPath = "C:\DevStackDownloads"
$LogFile = "$ProjectRoot\installation-log.txt"

# Functies
function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-DiskSpace {
    param(
        [string]$Drive = "C:",
        [int]$RequiredGB = 5
    )
    $disk = Get-PSDrive -Name $Drive.TrimEnd(':')
    $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)

    if ($freeSpaceGB -lt $RequiredGB) {
        Write-Host "  WARNING: Onvoldoende schijfruimte op drive $Drive" -ForegroundColor Red
        Write-Host "  Beschikbaar: $freeSpaceGB GB - Vereist: $RequiredGB GB" -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Check Administrator rechten
if (-not (Test-Administrator)) {
    Write-Host "ERROR: Dit script moet als Administrator worden uitgevoerd!" -ForegroundColor Red
    Write-Host "Klik rechts op PowerShell en kies 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Log "=== Start installatie Development Stack ==="
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Development Stack Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check schijfruimte
Write-Host "`nControleren systeem vereisten..." -ForegroundColor Gray
if (-not (Test-DiskSpace -Drive "C:" -RequiredGB 5)) {
    Write-Host "`nWARNING: Onvoldoende schijfruimte. Minimaal 5GB vrij nodig." -ForegroundColor Red
    Write-Host "Wil je toch doorgaan? (j/n)" -ForegroundColor Yellow
    $Continue = Read-Host
    if ($Continue -ne "j" -and $Continue -ne "J") {
        Write-Host "Installatie geannuleerd." -ForegroundColor Yellow
        exit 1
    }
} else {
    $disk = Get-PSDrive -Name C
    $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
    Write-Host "  Schijfruimte OK: $freeSpaceGB GB beschikbaar" -ForegroundColor Green
}

# Maak download directory
New-Item -ItemType Directory -Force -Path $DownloadPath | Out-Null
Write-Log "Download directory: $DownloadPath"

# 1. XAMPP handmatige installatie vereist
Write-Host "`n[1/6] XAMPP (Apache + PHP 8.2) - Handmatige installatie vereist" -ForegroundColor Yellow
Write-Log "XAMPP handmatige installatie check"

if (-not (Test-Path "C:\xampp")) {
    Write-Host "`n  BELANGRIJK: XAMPP moet handmatig worden geinstalleerd!" -ForegroundColor Red
    Write-Host "`n  Installatie instructies:" -ForegroundColor Cyan
    Write-Host "  1. Download XAMPP van: https://www.apachefriends.org/" -ForegroundColor White
    Write-Host "     - Kies versie 8.2.12 voor Windows" -ForegroundColor Gray
    Write-Host "     - Download link: https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/" -ForegroundColor Gray
    Write-Host "`n  2. Voer het gedownloade bestand uit" -ForegroundColor White
    Write-Host "     - Installeer naar C:\xampp (standaard locatie)" -ForegroundColor Gray
    Write-Host "     - Accepteer de standaard instellingen" -ForegroundColor Gray
    Write-Host "`n  3. Start dit script opnieuw nadat XAMPP is geinstalleerd" -ForegroundColor White
    Write-Host "`n=====================================" -ForegroundColor Red
    Write-Host "  XAMPP NIET GEVONDEN" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "`nInstalleer eerst XAMPP voordat je verder gaat!" -ForegroundColor Yellow
    Write-Host "Druk op een toets om het script af te sluiten..." -ForegroundColor Cyan
    Write-Log "XAMPP niet gevonden - handmatige installatie vereist"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
} else {
    Write-Host "  XAMPP is gevonden in C:\xampp" -ForegroundColor Green
    Write-Log "XAMPP installatie gedetecteerd"

    # Verificeer of essentiële onderdelen aanwezig zijn
    $XamppComponents = @("apache", "php", "mysql")
    $MissingComponents = @()

    foreach ($component in $XamppComponents) {
        if (-not (Test-Path "C:\xampp\$component")) {
            $MissingComponents += $component
        }
    }

    if ($MissingComponents.Count -gt 0) {
        Write-Host "  WAARSCHUWING: Ontbrekende XAMPP componenten: $($MissingComponents -join ', ')" -ForegroundColor Yellow
        Write-Log "WARNING: Ontbrekende XAMPP componenten: $($MissingComponents -join ', ')"
    } else {
        Write-Host "  Alle XAMPP componenten aanwezig" -ForegroundColor Green
    }
}

# 2. Composer installatie
Write-Host "`n[2/6] Composer installeren..." -ForegroundColor Yellow
$ComposerInstaller = "$DownloadPath\composer-setup.exe"

if (-not (Get-Command composer -ErrorAction SilentlyContinue)) {
    Write-Log "Download Composer..."
    try {
        Invoke-WebRequest -Uri "https://getcomposer.org/Composer-Setup.exe" -OutFile $ComposerInstaller
        Write-Log "Start Composer installatie..."
        Start-Process -FilePath $ComposerInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait

        # Voeg Composer toe aan PATH
        $env:Path += ";C:\ProgramData\ComposerSetup\bin"
        Write-Host "  Composer geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: Composer installatie mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://getcomposer.org/download/" -ForegroundColor Red
    }
} else {
    Write-Host "  Composer is al geinstalleerd" -ForegroundColor Green
}

# 3. Git installatie
Write-Host "`n[3/6] Git installeren..." -ForegroundColor Yellow 
$GitInstaller = "$DownloadPath\git-installer.exe"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "Download Git..."
    try {
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile $GitInstaller
        Write-Log "Start Git installatie..."
        Start-Process -FilePath $GitInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
        Write-Host "  Git geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: Git installatie mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://git-scm.com/download/win" -ForegroundColor Red
    }
} else {
    Write-Host "  Git is al geinstalleerd" -ForegroundColor Green
}

# 4. SQL Server Express installatie
<#
Write-Host "`n[4/7] SQL Server Express 2022 installeren..." -ForegroundColor Yellow
Write-Host "  Wil je SQL Server Express lokaal installeren? (j/n)" -ForegroundColor Cyan
Write-Host "  (Typ 'n' als je de schoolserver gebruikt)" -ForegroundColor Gray
$InstallSQL = Read-Host

if ($InstallSQL -eq "j" -or $InstallSQL -eq "J") {
    $SQLInstaller = "$DownloadPath\sql-server-express.exe"
    Write-Log "Download SQL Server Express..."
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/5/1/4/5145fe04-4d30-4b85-b0d1-39533663a2f1/SQL2022-SSEI-Expr.exe" -OutFile $SQLInstaller
        Write-Log "Start SQL Server installatie..."
        Start-Process -FilePath $SQLInstaller -ArgumentList "/ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS /SECURITYMODE=SQL /SAPWD=YourStrong!Password123 /IACCEPTSQLSERVERLICENSETERMS /QUIET" -Wait
        Write-Host "  SQL Server Express geinstalleerd!" -ForegroundColor Green
        Write-Log "SQL Server SA password: YourStrong!Password123"
    } catch {
        Write-Log "ERROR: SQL Server installatie mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://www.microsoft.com/sql-server/sql-server-downloads" -ForegroundColor Red
    }
} else {
    Write-Host "  SQL Server installatie overgeslagen" -ForegroundColor Yellow
}
#>

# 5. SQL Server Management Studio
<#
Write-Host "`n[5/7] SQL Server Management Studio (SSMS) installeren..." -ForegroundColor Yellow
Write-Host "  Wil je SSMS installeren? (j/n)" -ForegroundColor Cyan
$InstallSSMS = Read-Host

if ($InstallSSMS -eq "j" -or $InstallSSMS -eq "J") {
    $SSMSInstaller = "$DownloadPath\ssms-installer.exe"
    Write-Log "Download SSMS..."
    try {
        Invoke-WebRequest -Uri "https://aka.ms/ssmsfullsetup" -OutFile $SSMSInstaller
        Write-Log "Start SSMS installatie..."
        Start-Process -FilePath $SSMSInstaller -ArgumentList "/install /quiet /norestart" -Wait
        Write-Host "  SSMS geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: SSMS installatie mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://aka.ms/ssmsfullsetup" -ForegroundColor Red
    }
} else {
    Write-Host "  SSMS installatie overgeslagen" -ForegroundColor Yellow
}
#>

# 4. Visual Studio Code installatie

Write-Host "`n[4/6] Visual Studio Code installeren..." -ForegroundColor Yellow
Write-Host "  Wil je VS Code installeren? (j/n)" -ForegroundColor Cyan
$InstallVSCode = Read-Host

if ($InstallVSCode -eq "j" -or $InstallVSCode -eq "J") {
    $VSCodeInstaller = "$DownloadPath\vscode-installer.exe"
    Write-Log "Download VS Code..."
    try {
        Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -OutFile $VSCodeInstaller
        Write-Log "Start VS Code installatie..." 
        Start-Process -FilePath $VSCodeInstaller -ArgumentList "/VERYSILENT /MERGETASKS=!runcode" -Wait
        Write-Host "  VS Code geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: VS Code installatie mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://code.visualstudio.com/" -ForegroundColor Red
    }

    # 4a. VS Code extensies installeren
    # setup-vscode-php.ps1
    Write-Host "=== VS Code PHP Setup ===" -ForegroundColor Cyan
    # Zoek VS Code installatie
    $codePaths = @(
        "C:\Program Files\Microsoft VS Code\bin\code.cmd",
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
    )

    $codeCmd = $codePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $codeCmd) {
        Write-Error "VS Code niet gevonden! Installeer eerst VS Code."
        exit 1
    }

    Write-Host "VS Code gevonden: $codeCmd" -ForegroundColor Green

    # PHP extensies
    $extensions = @(
        "bmewburn.vscode-intelephense-client",
        "xdebug.php-debug"
    )

    Write-Host "`nInstalleren van extensies..." -ForegroundColor Yellow

    foreach ($ext in $extensions) {
        Write-Host "  - $ext" -ForegroundColor Gray
        & $codeCmd --install-extension $ext --force 2>$null
    }

    Write-Host "`nGeïnstalleerde PHP extensies:" -ForegroundColor Green
    & $codeCmd --list-extensions | Select-String "php|intelephense"

    Write-Host "`nKlaar!" -ForegroundColor Cyan

} else {
    Write-Host "  VS Code installatie overgeslagen" -ForegroundColor Yellow
}



# 5. PHP Configuratie en extensies
Write-Host "`n[5/6] PHP configureren en SQL Server drivers installeren..." -ForegroundColor Yellow

if (Test-Path "C:\xampp\php") {
    $PhpPath = "C:\xampp\php"
    $PhpIniPath = "$PhpPath\php.ini"

    Write-Log "Configureer PHP..."

    # Backup originele php.ini
    if (Test-Path $PhpIniPath) {
        Copy-Item $PhpIniPath "$PhpIniPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    } else {
        Copy-Item "$PhpPath\php.ini-development" $PhpIniPath
    }

    # Download SQL Server drivers voor PHP
    Write-Log "Download Microsoft SQL Server drivers voor PHP..."
    $SqlSrvPath = "$DownloadPath\sqlsrv-drivers.zip"
    try {
        # Download SQLSRV drivers (versie 5.11 voor PHP 8.2)
        Invoke-WebRequest -Uri "https://github.com/microsoft/msphpsql/releases/download/v5.11.1/Windows-8.2.zip" -OutFile $SqlSrvPath

        # Extract drivers
        Expand-Archive -Path $SqlSrvPath -DestinationPath "$DownloadPath\sqlsrv" -Force

        # Kopieer de juiste drivers naar PHP ext directory
        $PhpExtPath = "$PhpPath\ext"
        Copy-Item "$DownloadPath\sqlsrv\*\php_sqlsrv_82_ts_x64.dll" "$PhpExtPath\php_sqlsrv.dll" -Force
        Copy-Item "$DownloadPath\sqlsrv\*\php_pdo_sqlsrv_82_ts_x64.dll" "$PhpExtPath\php_pdo_sqlsrv.dll" -Force

        Write-Host "  SQL Server drivers gekopieerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: SQL Server drivers download mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://github.com/microsoft/msphpsql/releases" -ForegroundColor Red
    }

    # Download en installeer Xdebug
    Write-Log "Download Xdebug..."
    try {
        $XdebugDll = "$DownloadPath\php_xdebug.dll"
        # Xdebug 3.3 voor PHP 8.2
        Invoke-WebRequest -Uri "https://xdebug.org/files/php_xdebug-3.3.1-8.2-vs16-x86_64.dll" -OutFile $XdebugDll
        Copy-Item $XdebugDll "$PhpPath\ext\php_xdebug.dll" -Force
        Write-Host "  Xdebug gekopieerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: Xdebug download mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://xdebug.org/download" -ForegroundColor Red
    }

    # Pas php.ini aan
    Write-Log "Update php.ini met benodigde extensies..."
    $PhpIniContent = Get-Content $PhpIniPath -Raw

    # Activeer extensies (verwijder ; voor deze regels)
    $PhpIniContent = $PhpIniContent -replace ';extension=mbstring', 'extension=mbstring'
    $PhpIniContent = $PhpIniContent -replace ';extension=intl', 'extension=intl'
    $PhpIniContent = $PhpIniContent -replace ';extension=openssl', 'extension=openssl'
    $PhpIniContent = $PhpIniContent -replace ';extension=pdo_mysql', 'extension=pdo_mysql'
    $PhpIniContent = $PhpIniContent -replace ';extension=curl', 'extension=curl'

    # Voeg SQL Server extensies toe
    if ($PhpIniContent -notmatch "extension=sqlsrv") {
        $PhpIniContent += "`nextension=sqlsrv`nextension=pdo_sqlsrv`n"
    }

    # Voeg Xdebug configuratie toe
    if ($PhpIniContent -notmatch "zend_extension=xdebug") {
        $XdebugConfig = @"

; Xdebug Configuration
[xdebug]
zend_extension=xdebug
xdebug.mode=develop,debug
xdebug.start_with_request=yes
xdebug.client_host=127.0.0.1
xdebug.client_port=9003
xdebug.log=C:\xampp\tmp\xdebug.log
xdebug.idekey=VSCODE
"@
        $PhpIniContent += $XdebugConfig
    }

    # Andere instellingen
    $PhpIniContent = $PhpIniContent -replace 'memory_limit = .*', 'memory_limit = 256M'
    $PhpIniContent = $PhpIniContent -replace 'max_execution_time = .*', 'max_execution_time = 300'
    $PhpIniContent = $PhpIniContent -replace 'upload_max_filesize = .*', 'upload_max_filesize = 20M'
    $PhpIniContent = $PhpIniContent -replace 'post_max_size = .*', 'post_max_size = 20M'
    $PhpIniContent = $PhpIniContent -replace ';date.timezone =', 'date.timezone = Europe/Amsterdam'
    $PhpIniContent = $PhpIniContent -replace 'display_errors = Off', 'display_errors = On'
    $PhpIniContent = $PhpIniContent -replace 'error_reporting = .*', 'error_reporting = E_ALL'

    Set-Content -Path $PhpIniPath -Value $PhpIniContent
    Write-Host "  PHP.ini geconfigureerd!" -ForegroundColor Green

    # Configureer Apache voor CodeIgniter
    Write-Log "Configureer Apache voor CodeIgniter..."

    # Check of Virtual Hosts enabled zijn in httpd.conf
    $HttpdConf = "C:\xampp\apache\conf\httpd.conf"
    if (Test-Path $HttpdConf) {
        $HttpdContent = Get-Content $HttpdConf -Raw

        # Enable Virtual Hosts als ze nog niet enabled zijn
        if ($HttpdContent -match "#.*Include conf/extra/httpd-vhosts.conf") {
            Write-Host "  Enabling Virtual Hosts in httpd.conf..." -ForegroundColor Gray
            $HttpdContent = $HttpdContent -replace "#(.*Include conf/extra/httpd-vhosts.conf)", '$1'
            Set-Content -Path $HttpdConf -Value $HttpdContent
            Write-Log "Virtual Hosts enabled in httpd.conf"
        }
    }

    $ApacheConfPath = "C:\xampp\apache\conf\extra\httpd-vhosts.conf"
    if (Test-Path $ApacheConfPath) {
        # Check of onze configuratie al bestaat
        $VHostContent = Get-Content $ApacheConfPath -Raw

        if ($VHostContent -notmatch "CodeIgniter Virtual Host") {
            $VHostConfig = @"

# CodeIgniter Virtual Host
<VirtualHost *:80>
    DocumentRoot "C:/xampp/htdocs"
    ServerName localhost

    <Directory "C:/xampp/htdocs">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # CodeIgniter specifieke alias
    Alias /Examen "C:/xampp/htdocs/Examen/public"
    <Directory "C:/xampp/htdocs/Examen/public">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
"@
            Add-Content -Path $ApacheConfPath -Value $VHostConfig
            Write-Host "  Apache Virtual Host toegevoegd!" -ForegroundColor Green
            Write-Log "Apache Virtual Host configuratie toegevoegd"
        } else {
            Write-Host "  Apache Virtual Host al geconfigureerd" -ForegroundColor Gray
        }
    }

} else {
    Write-Log "WARNING: XAMPP PHP directory niet gevonden"
    Write-Host "  XAMPP niet gevonden - handmatige configuratie vereist" -ForegroundColor Red
}

# 6. CodeIgniter 4 Project setup
Write-Host "`n[6/6] CodeIgniter 4 Project setup..." -ForegroundColor Yellow

# Check of project al bestaat
$HtdocsPath = "C:\xampp\htdocs\Examen"

if (-not (Test-Path $HtdocsPath)) {
    Write-Log "Setup CodeIgniter 4 project..."

    # Optie 1: Kopieer bestaand project als het bestaat in project root
    if ((Test-Path "$ProjectRoot\app") -and (Test-Path "$ProjectRoot\composer.json")) {
        Write-Host "  Bestaand CodeIgniter project gevonden, kopieren..." -ForegroundColor Gray
        try {
            Copy-Item -Path $ProjectRoot -Destination "C:\xampp\htdocs\" -Recurse -Force
            # Hernoem naar Examen
            if (Test-Path "C:\xampp\htdocs\ExamenXampDocker") {
                Rename-Item "C:\xampp\htdocs\ExamenXampDocker" "Examen"
            }
            Write-Host "  Project gekopieerd naar $HtdocsPath" -ForegroundColor Green
            Write-Log "Bestaand project gekopieerd"
        } catch {
            Write-Log "ERROR: Project kopieren mislukt - $_"
            Write-Host "  ERROR: Kopieren mislukt - $_" -ForegroundColor Red
        }
    } else {
        # Optie 2: Maak nieuw CodeIgniter project via Composer
        Write-Host "  Nieuw CodeIgniter 4 project aanmaken..." -ForegroundColor Gray
        try {
            Set-Location "C:\xampp\htdocs"
            & composer create-project codeigniter4/appstarter Examen
            Write-Host "  Nieuw CodeIgniter project aangemaakt!" -ForegroundColor Green
            Write-Log "Nieuw CodeIgniter project aangemaakt via Composer"
        } catch {
            Write-Log "ERROR: CodeIgniter project aanmaken mislukt - $_"
            Write-Host "  ERROR: Project aanmaken mislukt - $_" -ForegroundColor Red
        }
    }
}

# Installeer/Update Composer dependencies
if (Test-Path "$HtdocsPath\composer.json") {
    Write-Log "Installeer Composer dependencies..."
    Set-Location $HtdocsPath
    try {
        if (Test-Path "$HtdocsPath\vendor") {
            Write-Host "  Composer dependencies updaten..." -ForegroundColor Gray
            & composer update
        } else {
            Write-Host "  Composer dependencies installeren..." -ForegroundColor Gray
            & composer install
        }
        Write-Host "  Composer dependencies geinstalleerd!" -ForegroundColor Green
        Write-Log "Composer dependencies geinstalleerd"
    } catch {
        Write-Log "ERROR: Composer install mislukt - $_"
        Write-Host "  ERROR: Composer install mislukt - $_" -ForegroundColor Red
    }
} else {
    Write-Host "  WARNING: Geen composer.json gevonden in $HtdocsPath" -ForegroundColor Yellow
}

# Verificeer CodeIgniter installatie
if (Test-Path "$HtdocsPath\spark") {
    Write-Host "  CodeIgniter CLI (spark) gevonden" -ForegroundColor Green

    # Test spark command
    try {
        $SparkVersion = & php "$HtdocsPath\spark" --version 2>&1 | Select-Object -First 1
        Write-Host "  $SparkVersion" -ForegroundColor Green
        Write-Log "CodeIgniter versie: $SparkVersion"
    } catch {
        Write-Host "  WARNING: Kon spark niet uitvoeren" -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARNING: CodeIgniter spark CLI niet gevonden" -ForegroundColor Yellow
}

# Maak writable directories
$WritableDirs = @("$HtdocsPath\writable", "$HtdocsPath\writable\cache", "$HtdocsPath\writable\logs", "$HtdocsPath\writable\session", "$HtdocsPath\writable\uploads")
foreach ($dir in $WritableDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# Download Microsoft ODBC Driver voor SQL Server
Write-Host "`nMicrosoft ODBC Driver 18 voor SQL Server installeren..." -ForegroundColor Yellow
Write-Host "  Wil je de ODBC driver installeren? (Nodig voor SQL Server connecties) (j/n)" -ForegroundColor Cyan
$InstallODBC = Read-Host

if ($InstallODBC -eq "j" -or $InstallODBC -eq "J") {
    $ODBCInstaller = "$DownloadPath\msodbcsql.msi"
    try {
        Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2249004" -OutFile $ODBCInstaller
        Start-Process msiexec.exe -ArgumentList "/i `"$ODBCInstaller`" /quiet /qn /norestart IACCEPTMSODBCSQLLICENSETERMS=YES" -Wait
        Write-Host "  ODBC Driver geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: ODBC Driver installatie mislukt - $_"
    }
}

# Cleanup
Remove-Item -Path $DownloadPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Log "=== Installatie voltooid ==="

# Samenvatting
Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Installatie Voltooid!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nVolgende stappen:" -ForegroundColor Cyan
Write-Host "1. Start XAMPP Control Panel: C:\xampp\xampp-control.exe" -ForegroundColor White
Write-Host "2. Start Apache en MySQL services" -ForegroundColor White
Write-Host "`n3. Open in browser:" -ForegroundColor White
Write-Host "   - XAMPP Dashboard: http://localhost/" -ForegroundColor Gray
Write-Host "   - CodeIgniter Project: http://localhost/Examen/" -ForegroundColor Gray
Write-Host "`n4. Configureer database in: $HtdocsPath\app\Config\Database.php" -ForegroundColor White
Write-Host "`nVoor VS Code debugging:" -ForegroundColor Cyan
Write-Host "- Installeer PHP Debug extensie" -ForegroundColor White
Write-Host "- Configureer launch.json voor Xdebug poort 9003" -ForegroundColor White
Write-Host "`nTroubleshooting:" -ForegroundColor Cyan
Write-Host "Als Apache niet start:" -ForegroundColor White
Write-Host "- Check of poort 80 bezet is: netstat -ano | findstr :80" -ForegroundColor Gray
Write-Host "- Stop andere webservers (IIS, Skype, etc.)" -ForegroundColor Gray
Write-Host "- Check Apache error log: C:\xampp\apache\logs\error.log" -ForegroundColor Gray
Write-Host "`nAls localhost niets toont:" -ForegroundColor White
Write-Host "- Check of Apache draait in XAMPP Control Panel" -ForegroundColor Gray
Write-Host "- Run health check: .\xampp-health-check.ps1" -ForegroundColor Gray
Write-Host "- Check Apache configuratie: C:\xampp\apache\conf\extra\httpd-vhosts.conf" -ForegroundColor Gray
Write-Host "`nLog bestand: $LogFile" -ForegroundColor Gray
Write-Host "`nDruk op een toets om af te sluiten..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
