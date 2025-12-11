# XAMPP Health Check Script
# Test of alle componenten correct geïnstalleerd en geconfigureerd zijn

$ErrorActionPreference = "SilentlyContinue"

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "     XAMPP Health Check" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$AllOK = $true

# 1. XAMPP Installatie Check
Write-Host "`n[1/10] XAMPP Installatie..." -ForegroundColor Yellow
if (Test-Path "C:\xampp") {
    Write-Host "  [OK] XAMPP geïnstalleerd in C:\xampp" -ForegroundColor Green

    # Check subdirectories
    $RequiredDirs = @("apache", "php", "htdocs")
    foreach ($dir in $RequiredDirs) {
        if (Test-Path "C:\xampp\$dir") {
            Write-Host "  [OK] $dir directory gevonden" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $dir directory niet gevonden" -ForegroundColor Red
            $AllOK = $false
        }
    }
} else {
    Write-Host "  [FAIL] XAMPP niet gevonden in C:\xampp" -ForegroundColor Red
    Write-Host "  Run eerst: .\windows-setup.ps1" -ForegroundColor Yellow
    $AllOK = $false
    exit 1
}

# 2. PHP Check
Write-Host "`n[2/10] PHP Installatie..." -ForegroundColor Yellow
$PhpExe = "C:\xampp\php\php.exe"
if (Test-Path $PhpExe) {
    $phpVersionOutput = & $PhpExe -v 2>&1
    if ($phpVersionOutput) {
        $versionLine = ($phpVersionOutput | Select-Object -First 1)
        Write-Host "  [OK] $versionLine" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] PHP niet uitvoerbaar" -ForegroundColor Red
        $AllOK = $false
    }
} else {
    Write-Host "  [FAIL] PHP executable niet gevonden" -ForegroundColor Red
    $AllOK = $false
}

# 3. Apache Check
Write-Host "`n[3/10] Apache Service..." -ForegroundColor Yellow
$ApacheProcess = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($ApacheProcess) {
    Write-Host "  [OK] Apache draait (PID: $($ApacheProcess[0].Id))" -ForegroundColor Green

    # Check Apache poort
    $NetStat = netstat -ano | Select-String ":80 " | Select-String "LISTENING"
    if ($NetStat) {
        Write-Host "  [OK] Apache luistert op poort 80" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Poort 80 niet in gebruik - Apache mogelijk op andere poort" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WARN] Apache draait niet" -ForegroundColor Yellow
    Write-Host "  Start Apache via: C:\xampp\xampp-control.exe" -ForegroundColor Gray
}

# 4. Apache Configuratie Check
Write-Host "`n[4/10] Apache Configuratie..." -ForegroundColor Yellow
$HttpdConf = "C:\xampp\apache\conf\httpd.conf"
if (Test-Path $HttpdConf) {
    Write-Host "  [OK] httpd.conf gevonden" -ForegroundColor Green

    $ApacheExe = "C:\xampp\apache\bin\httpd.exe"
    if (Test-Path $ApacheExe) {
        $apacheVersion = & $ApacheExe -v 2>&1 | Select-Object -First 1
        Write-Host "  [OK] $apacheVersion" -ForegroundColor Green

        # Test Apache configuratie syntax
        $ApacheTest = & $ApacheExe -t 2>&1
        if ($ApacheTest -match "Syntax OK") {
            Write-Host "  [OK] Apache configuratie syntax is correct" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] Apache configuratie bevat fouten" -ForegroundColor Red
            Write-Host "  Run: C:\xampp\apache\bin\httpd.exe -t" -ForegroundColor Gray
            $AllOK = $false
        }
    }

    # Check of Virtual Hosts enabled zijn
    $HttpdContent = Get-Content $HttpdConf -Raw
    if ($HttpdContent -match "^\s*Include conf/extra/httpd-vhosts.conf" -and $HttpdContent -notmatch "#.*Include conf/extra/httpd-vhosts.conf") {
        Write-Host "  [OK] Virtual Hosts zijn enabled" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Virtual Hosts zijn niet enabled (optioneel)" -ForegroundColor Gray
    }

    # Check Virtual Host configuratie
    $VHostConf = "C:\xampp\apache\conf\extra\httpd-vhosts.conf"
    if (Test-Path $VHostConf) {
        $VHostContent = Get-Content $VHostConf -Raw
        if ($VHostContent -match "CodeIgniter Virtual Host") {
            Write-Host "  [OK] CodeIgniter Virtual Host geconfigureerd" -ForegroundColor Green
        } else {
            Write-Host "  [INFO] CodeIgniter Virtual Host nog niet geconfigureerd" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  [FAIL] httpd.conf niet gevonden" -ForegroundColor Red
    $AllOK = $false
}

# 5. PHP Configuratie
Write-Host "`n[5/10] PHP Configuratie (php.ini)..." -ForegroundColor Yellow
$PhpIni = "C:\xampp\php\php.ini"
if (Test-Path $PhpIni) {
    Write-Host "  [OK] php.ini gevonden" -ForegroundColor Green

    # Check belangrijke settings
    $IniContent = Get-Content $PhpIni -Raw

    if ($IniContent -match "display_errors\s*=\s*On") {
        Write-Host "  [OK] display_errors = On" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] display_errors = Off (gebruik On voor development)" -ForegroundColor Gray
    }

    if ($IniContent -match "date.timezone\s*=\s*\w+") {
        Write-Host "  [OK] date.timezone geconfigureerd" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] date.timezone niet geconfigureerd" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [FAIL] php.ini niet gevonden" -ForegroundColor Red
    $AllOK = $false
}

# 6. PHP Extensies
Write-Host "`n[6/10] PHP Extensies..." -ForegroundColor Yellow
$Extensions = & $PhpExe -m 2>&1

$RequiredExtensions = @("mbstring", "intl", "openssl", "curl", "mysqli")
foreach ($ext in $RequiredExtensions) {
    if ($Extensions -match $ext) {
        Write-Host "  [OK] $ext geladen" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] $ext niet geladen" -ForegroundColor Yellow
    }
}

# 7. SQL Server Drivers
Write-Host "`n[7/10] SQL Server Drivers..." -ForegroundColor Yellow
if ($Extensions -match "sqlsrv") {
    Write-Host "  [OK] sqlsrv extensie geladen" -ForegroundColor Green
} else {
    Write-Host "  [WARN] sqlsrv niet geladen" -ForegroundColor Yellow
    Write-Host "  Controleer: C:\xampp\php\ext\php_sqlsrv.dll" -ForegroundColor Gray
}

if ($Extensions -match "pdo_sqlsrv") {
    Write-Host "  [OK] pdo_sqlsrv extensie geladen" -ForegroundColor Green
} else {
    Write-Host "  [WARN] pdo_sqlsrv niet geladen" -ForegroundColor Yellow
    Write-Host "  Controleer: C:\xampp\php\ext\php_pdo_sqlsrv.dll" -ForegroundColor Gray
}

# Check DLL files
$SqlsrvDll = "C:\xampp\php\ext\php_sqlsrv.dll"
$PdoSqlsrvDll = "C:\xampp\php\ext\php_pdo_sqlsrv.dll"

if (Test-Path $SqlsrvDll) {
    Write-Host "  [OK] php_sqlsrv.dll gevonden" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] php_sqlsrv.dll niet gevonden" -ForegroundColor Red
}

if (Test-Path $PdoSqlsrvDll) {
    Write-Host "  [OK] php_pdo_sqlsrv.dll gevonden" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] php_pdo_sqlsrv.dll niet gevonden" -ForegroundColor Red
}

# 8. Xdebug
Write-Host "`n[8/10] Xdebug..." -ForegroundColor Yellow
if ($Extensions -match "xdebug") {
    Write-Host "  [OK] Xdebug extensie geladen" -ForegroundColor Green

    # Check Xdebug versie
    $XdebugInfo = & $PhpExe -v 2>&1 | Select-String "Xdebug"
    if ($XdebugInfo) {
        Write-Host "  [OK] $XdebugInfo" -ForegroundColor Green
    }
} else {
    Write-Host "  [WARN] Xdebug niet geladen" -ForegroundColor Yellow
    Write-Host "  Debugging in VS Code zal niet werken" -ForegroundColor Gray
}

$XdebugDll = "C:\xampp\php\ext\php_xdebug.dll"
if (Test-Path $XdebugDll) {
    Write-Host "  [OK] php_xdebug.dll gevonden" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] php_xdebug.dll niet gevonden" -ForegroundColor Red
}

# 9. Composer Check
Write-Host "`n[9/10] Composer..." -ForegroundColor Yellow
$ComposerCmd = Get-Command composer -ErrorAction SilentlyContinue
if ($ComposerCmd) {
    $ComposerVersion = & composer --version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] $ComposerVersion" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Composer niet gevonden in PATH" -ForegroundColor Yellow
    Write-Host "  Probeer: composer install in project directory" -ForegroundColor Gray
}

# 10. CodeIgniter 4 Project Setup
Write-Host "`n[10/10] CodeIgniter 4 Project..." -ForegroundColor Yellow
$ProjectPath = "C:\xampp\htdocs\Examen"
if (Test-Path $ProjectPath) {
    Write-Host "  [OK] Project gevonden in $ProjectPath" -ForegroundColor Green

    # Check CodeIgniter directories
    $CIDirectories = @("app", "public", "writable", "app\Config", "app\Controllers", "app\Models", "app\Views")
    foreach ($dir in $CIDirectories) {
        if (Test-Path "$ProjectPath\$dir") {
            Write-Host "  [OK] $dir directory gevonden" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $dir directory niet gevonden" -ForegroundColor Red
            $AllOK = $false
        }
    }

    # Check composer dependencies
    if (Test-Path "$ProjectPath\vendor") {
        Write-Host "  [OK] Composer dependencies geïnstalleerd" -ForegroundColor Green

        # Check CodeIgniter framework
        if (Test-Path "$ProjectPath\vendor\codeigniter4\framework") {
            Write-Host "  [OK] CodeIgniter 4 framework gevonden" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] CodeIgniter 4 framework niet gevonden" -ForegroundColor Red
            $AllOK = $false
        }
    } else {
        Write-Host "  [WARN] Vendor directory niet gevonden" -ForegroundColor Yellow
        Write-Host "  Run: composer install in $ProjectPath" -ForegroundColor Gray
    }

    # Check CodeIgniter CLI (spark)
    if (Test-Path "$ProjectPath\spark") {
        Write-Host "  [OK] CodeIgniter CLI (spark) gevonden" -ForegroundColor Green

        # Test spark command
        Set-Location $ProjectPath
        $SparkTest = & $PhpExe spark --version 2>&1
        if ($SparkTest) {
            $SparkVersion = $SparkTest | Select-Object -First 1
            Write-Host "  [OK] $SparkVersion" -ForegroundColor Green
        }
    } else {
        Write-Host "  [FAIL] spark CLI niet gevonden" -ForegroundColor Red
        $AllOK = $false
    }

    # Check env file
    if (Test-Path "$ProjectPath\env") {
        Write-Host "  [INFO] env template file gevonden" -ForegroundColor Gray
        if (-not (Test-Path "$ProjectPath\.env")) {
            Write-Host "  [WARN] .env file niet gevonden (kopieer van env)" -ForegroundColor Yellow
            Write-Host "  Run: copy env .env in $ProjectPath" -ForegroundColor Gray
        } else {
            Write-Host "  [OK] .env configuratie file gevonden" -ForegroundColor Green
        }
    }

    # Check writable permissions
    $WritableDirs = @("writable\cache", "writable\logs", "writable\session", "writable\uploads")
    $PermissionIssues = $false
    foreach ($dir in $WritableDirs) {
        $fullPath = "$ProjectPath\$dir"
        if (Test-Path $fullPath) {
            try {
                $testFile = "$fullPath\test-write-$(Get-Date -Format 'yyyyMMddHHmmss').tmp"
                "test" | Out-File -FilePath $testFile -ErrorAction Stop
                Remove-Item $testFile -ErrorAction SilentlyContinue
            } catch {
                Write-Host "  [WARN] $dir niet schrijfbaar" -ForegroundColor Yellow
                $PermissionIssues = $true
            }
        }
    }
    if (-not $PermissionIssues) {
        Write-Host "  [OK] Writable directories zijn schrijfbaar" -ForegroundColor Green
    }

    # Check key CodeIgniter files
    $KeyFiles = @("app\Config\App.php", "app\Config\Database.php", "app\Controllers\Home.php")
    foreach ($file in $KeyFiles) {
        if (Test-Path "$ProjectPath\$file") {
            Write-Host "  [OK] $file gevonden" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $file niet gevonden" -ForegroundColor Red
            $AllOK = $false
        }
    }

} else {
    Write-Host "  [INFO] CodeIgniter project nog niet geïnstalleerd" -ForegroundColor Gray
    Write-Host "  Run: .\windows-setup.ps1" -ForegroundColor Gray
}

# Test Web Server Response
Write-Host "`n[BONUS] Web Server Test..." -ForegroundColor Yellow
if ($ApacheProcess) {
    try {
        $Response = Invoke-WebRequest -Uri "http://localhost" -TimeoutSec 5 -UseBasicParsing
        if ($Response.StatusCode -eq 200) {
            Write-Host "  [OK] Apache reageert op http://localhost" -ForegroundColor Green
            Write-Host "  [OK] Status Code: $($Response.StatusCode)" -ForegroundColor Green

            # Check of het een CodeIgniter response is
            if ($Response.Content -match "CodeIgniter" -or $Response.Content -match "Welcome to CodeIgniter") {
                Write-Host "  [OK] CodeIgniter welkomstpagina wordt getoond" -ForegroundColor Green
            } elseif ($Response.Content -match "XAMPP") {
                Write-Host "  [INFO] XAMPP dashboard wordt getoond (geen CodeIgniter)" -ForegroundColor Gray
                Write-Host "  Check Apache Virtual Host configuratie" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "  [WARN] Kon geen verbinding maken met http://localhost" -ForegroundColor Yellow
        Write-Host "  Controleer of Apache draait en op poort 80 luistert" -ForegroundColor Gray
    }
} else {
    Write-Host "  [SKIP] Apache draait niet - kan niet testen" -ForegroundColor Gray
}

# Samenvatting
Write-Host "`n=====================================" -ForegroundColor Cyan
if ($AllOK) {
    Write-Host "  Status: ALLES OK!" -ForegroundColor Green
} else {
    Write-Host "  Status: ENKELE PROBLEMEN" -ForegroundColor Yellow
}
Write-Host "=====================================" -ForegroundColor Cyan

# Snelle actie links
Write-Host "`nSnelle Acties:" -ForegroundColor Cyan
Write-Host "  Start XAMPP Control Panel:" -ForegroundColor White
Write-Host "    C:\xampp\xampp-control.exe" -ForegroundColor Gray
Write-Host "`n  Open in browser:" -ForegroundColor White
Write-Host "    XAMPP Dashboard: http://localhost" -ForegroundColor Gray
Write-Host "    CodeIgniter App: http://localhost/Examen/" -ForegroundColor Gray
Write-Host "`n  Test PHP info:" -ForegroundColor White
Write-Host "    http://localhost/dashboard/phpinfo.php" -ForegroundColor Gray
Write-Host "`n  Check Apache error log:" -ForegroundColor White
Write-Host "    Get-Content C:\xampp\apache\logs\error.log -Tail 50" -ForegroundColor Gray
Write-Host "`n  View installation log:" -ForegroundColor White
Write-Host "    Get-Content .\installation-log.txt" -ForegroundColor Gray

if (Test-Path "C:\xampp\htdocs\Examen") {
    Write-Host "`nCodeIgniter Commands:" -ForegroundColor Cyan
    Write-Host "  Start development server:" -ForegroundColor White
    Write-Host "    cd C:\xampp\htdocs\Examen && php spark serve" -ForegroundColor Gray
    Write-Host "`n  List all routes:" -ForegroundColor White
    Write-Host "    cd C:\xampp\htdocs\Examen && php spark routes" -ForegroundColor Gray
    Write-Host "`n  Create migration:" -ForegroundColor White
    Write-Host "    cd C:\xampp\htdocs\Examen && php spark make:migration <name>" -ForegroundColor Gray
    Write-Host "`n  Create controller:" -ForegroundColor White
    Write-Host "    cd C:\xampp\htdocs\Examen && php spark make:controller <name>" -ForegroundColor Gray
    Write-Host "`n  Create model:" -ForegroundColor White
    Write-Host "    cd C:\xampp\htdocs\Examen && php spark make:model <name>" -ForegroundColor Gray
}

Write-Host "`n"
