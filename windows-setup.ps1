# Windows 10 Development Stack Installation Script
# Voor CodeIgniter 4 met SQL Server
# Run dit script als Administrator in PowerShell

# Configuratie
$ProjectRoot = $PSScriptRoot
$DownloadPath = "$env:TEMP\DevStackDownloads"
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

# Check Administrator rechten
if (-not (Test-Administrator)) {
    Write-Host "ERROR: Dit script moet als Administrator worden uitgevoerd!" -ForegroundColor Red
    Write-Host "Klik rechts op PowerShell en kies 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Maak download directory
New-Item -ItemType Directory -Force -Path $DownloadPath | Out-Null

Write-Log "=== Start installatie Development Stack ==="
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Development Stack Installer" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# 1. XAMPP installatie
Write-Host "`n[1/7] XAMPP (Apache + PHP 8.2) installeren..." -ForegroundColor Yellow
$XamppInstaller = "$DownloadPath\xampp-installer.exe"
$XamppUrl = "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download"

if (-not (Test-Path "C:\xampp")) {
    Write-Log "Download XAMPP..."
    try {
        Invoke-WebRequest -Uri $XamppUrl -OutFile $XamppInstaller -UseBasicParsing
        Write-Log "Start XAMPP installatie..."
        Start-Process -FilePath $XamppInstaller -ArgumentList "--mode unattended --launchapps 0" -Wait
        Write-Host "  XAMPP geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: XAMPP installatie mislukt - $_"
        Write-Host "  Handmatig downloaden van: https://www.apachefriends.org/" -ForegroundColor Red
    }
} else {
    Write-Host "  XAMPP is al geinstalleerd" -ForegroundColor Green
}

# 2. Composer installatie
Write-Host "`n[2/7] Composer installeren..." -ForegroundColor Yellow
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
Write-Host "`n[3/7] Git installeren..." -ForegroundColor Yellow
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

# 6. Visual Studio Code installatie
Write-Host "`n[6/7] Visual Studio Code installeren..." -ForegroundColor Yellow
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
} else {
    Write-Host "  VS Code installatie overgeslagen" -ForegroundColor Yellow
}


# 7. PHP Configuratie en extensies
Write-Host "`n[7/7] PHP configureren en SQL Server drivers installeren..." -ForegroundColor Yellow

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
    $ApacheConfPath = "C:\xampp\apache\conf\extra\httpd-vhosts.conf"

    if (Test-Path $ApacheConfPath) {
        $VHostConfig = @"

# CodeIgniter Virtual Host
<VirtualHost *:80>
    DocumentRoot "C:/xampp/htdocs/Examen/public"
    ServerName localhost

    <Directory "C:/xampp/htdocs/Examen/public">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
"@
        Add-Content -Path $ApacheConfPath -Value $VHostConfig
        Write-Host "  Apache Virtual Host toegevoegd!" -ForegroundColor Green
    }

} else {
    Write-Log "WARNING: XAMPP PHP directory niet gevonden"
    Write-Host "  XAMPP niet gevonden - handmatige configuratie vereist" -ForegroundColor Red
}

# 8. Project setup
Write-Host "`n[8/8] Project setup..." -ForegroundColor Yellow

# Kopieer project naar XAMPP htdocs
$HtdocsPath = "C:\xampp\htdocs\Examen"
if (-not (Test-Path $HtdocsPath)) {
    Write-Log "Kopieer project naar XAMPP htdocs..."
    try {
        Copy-Item -Path $ProjectRoot -Destination "C:\xampp\htdocs\" -Recurse -Force
        Write-Host "  Project gekopieerd naar $HtdocsPath" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: Project kopieren mislukt - $_"
    }
}

# Installeer Composer dependencies
if (Test-Path "$HtdocsPath\composer.json") {
    Write-Log "Installeer Composer dependencies..."
    Set-Location $HtdocsPath
    try {
        & composer install
        Write-Host "  Composer dependencies geinstalleerd!" -ForegroundColor Green
    } catch {
        Write-Log "ERROR: Composer install mislukt - $_"
    }
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
Write-Host "3. Open project in browser: http://localhost/" -ForegroundColor White
Write-Host "4. Configureer database in: $HtdocsPath\app\Config\Database.php" -ForegroundColor White
Write-Host "`nVoor VS Code debugging:" -ForegroundColor Cyan
Write-Host "- Installeer PHP Debug extensie" -ForegroundColor White
Write-Host "- Configureer launch.json voor Xdebug poort 9003" -ForegroundColor White
Write-Host "`nLog bestand: $LogFile" -ForegroundColor Gray
Write-Host "`nDruk op een toets om af te sluiten..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
