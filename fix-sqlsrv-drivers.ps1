# Fix SQL Server Drivers voor XAMPP
# Lost problemen op met ontbrekende php_sqlsrv en php_pdo_sqlsrv DLL's

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  SQL Server Driver Diagnose & Fix" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$PhpExe = "C:\xampp\php\php.exe"
$PhpExtDir = "C:\xampp\php\ext"
$PhpIni = "C:\xampp\php\php.ini"

# 1. Check huidige status
Write-Host "`n[1/4] Controleren huidige status..." -ForegroundColor Yellow

if (-not (Test-Path $PhpExe)) {
    Write-Host "  [FAIL] PHP niet gevonden in C:\xampp\php" -ForegroundColor Red
    exit 1
}

# Haal PHP versie op
$PhpVersion = & $PhpExe -r "echo PHP_VERSION;" 2>&1
$PhpVersionShort = $PhpVersion -replace '(\d+\.\d+).*', '$1'
Write-Host "  [INFO] PHP Versie: $PhpVersion" -ForegroundColor Gray
Write-Host "  [INFO] PHP Versie (kort): $PhpVersionShort" -ForegroundColor Gray

# Check of extensies geladen zijn
$LoadedExtensions = & $PhpExe -m 2>&1
$SqlsrvLoaded = $LoadedExtensions -match "sqlsrv"
$PdoSqlsrvLoaded = $LoadedExtensions -match "pdo_sqlsrv"

if ($SqlsrvLoaded) {
    Write-Host "  [OK] sqlsrv extensie is geladen" -ForegroundColor Green
} else {
    Write-Host "  [WARN] sqlsrv extensie niet geladen" -ForegroundColor Yellow
}

if ($PdoSqlsrvLoaded) {
    Write-Host "  [OK] pdo_sqlsrv extensie is geladen" -ForegroundColor Green
} else {
    Write-Host "  [WARN] pdo_sqlsrv extensie niet geladen" -ForegroundColor Yellow
}

# 2. Zoek naar DLL bestanden
Write-Host "`n[2/4] Zoeken naar SQL Server driver DLL's..." -ForegroundColor Yellow

# Zoek in verschillende locaties
$SearchPaths = @(
    "C:\xampp\php\ext",
    "C:\xampp\php",
    "C:\php\ext",
    "$env:SYSTEMROOT\System32"
)

$SqlsrvFiles = @()
$PdoSqlsrvFiles = @()

foreach ($path in $SearchPaths) {
    if (Test-Path $path) {
        $found = Get-ChildItem -Path $path -Filter "*sqlsrv*.dll" -ErrorAction SilentlyContinue
        foreach ($file in $found) {
            if ($file.Name -like "php_sqlsrv*.dll") {
                $SqlsrvFiles += $file.FullName
                Write-Host "  [FOUND] $($file.FullName)" -ForegroundColor Cyan
            }
            if ($file.Name -like "php_pdo_sqlsrv*.dll") {
                $PdoSqlsrvFiles += $file.FullName
                Write-Host "  [FOUND] $($file.FullName)" -ForegroundColor Cyan
            }
        }
    }
}

# 3. Check php.ini configuratie
Write-Host "`n[3/4] Controleren php.ini configuratie..." -ForegroundColor Yellow

if (Test-Path $PhpIni) {
    $IniContent = Get-Content $PhpIni -Raw

    # Check of extension_dir correct is
    if ($IniContent -match 'extension_dir\s*=\s*"([^"]+)"') {
        $ExtDir = $matches[1]
        Write-Host "  [INFO] extension_dir = $ExtDir" -ForegroundColor Gray
    }

    # Check of sqlsrv extensies enabled zijn
    $SqlsrvEnabled = $IniContent -match '^\s*extension\s*=\s*sqlsrv' -or $IniContent -match '^\s*extension\s*=\s*php_sqlsrv'
    $PdoSqlsrvEnabled = $IniContent -match '^\s*extension\s*=\s*pdo_sqlsrv' -or $IniContent -match '^\s*extension\s*=\s*php_pdo_sqlsrv'

    if ($SqlsrvEnabled) {
        Write-Host "  [OK] sqlsrv extensie enabled in php.ini" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] sqlsrv extensie niet enabled in php.ini" -ForegroundColor Yellow
    }

    if ($PdoSqlsrvEnabled) {
        Write-Host "  [OK] pdo_sqlsrv extensie enabled in php.ini" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] pdo_sqlsrv extensie niet enabled in php.ini" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [FAIL] php.ini niet gevonden" -ForegroundColor Red
    exit 1
}

# 4. Oplossingen aanbieden
Write-Host "`n[4/4] Diagnose & Oplossingen..." -ForegroundColor Yellow

if ($SqlsrvLoaded -and $PdoSqlsrvLoaded) {
    Write-Host "`n  [SUCCESS] SQL Server drivers zijn correct geladen!" -ForegroundColor Green
    Write-Host "  De DLL bestanden zijn actief, ook al worden ze niet gevonden op de verwachte locatie." -ForegroundColor Gray
    Write-Host "  Dit kan gebeuren wanneer drivers via Microsoft's installer zijn geïnstalleerd." -ForegroundColor Gray

    # Test connectie mogelijkheden
    Write-Host "`n  Je kunt nu MS SQL Server gebruiken in je applicatie met:" -ForegroundColor Cyan
    Write-Host "  - sqlsrv_connect() voor native driver" -ForegroundColor White
    Write-Host "  - PDO met DSN: 'sqlsrv:Server=hostname;Database=dbname'" -ForegroundColor White

} elseif ($SqlsrvFiles.Count -gt 0 -or $PdoSqlsrvFiles.Count -gt 0) {
    Write-Host "`n  [INFO] DLL bestanden gevonden, maar niet geladen" -ForegroundColor Yellow
    Write-Host "`n  De drivers zijn geïnstalleerd maar mogelijk:" -ForegroundColor Gray
    Write-Host "  1. Niet enabled in php.ini" -ForegroundColor White
    Write-Host "  2. Verkeerde PHP versie (mismatch tussen PHP en driver versie)" -ForegroundColor White
    Write-Host "  3. Microsoft Visual C++ Redistributable ontbreekt" -ForegroundColor White

    Write-Host "`n  Handmatige stappen:" -ForegroundColor Cyan
    Write-Host "  1. Open php.ini: $PhpIni" -ForegroundColor White
    Write-Host "  2. Zoek naar de sectie met 'extension=' regels" -ForegroundColor White
    Write-Host "  3. Voeg toe (of uncomment):" -ForegroundColor White
    Write-Host "     extension=sqlsrv" -ForegroundColor Gray
    Write-Host "     extension=pdo_sqlsrv" -ForegroundColor Gray
    Write-Host "  4. Herstart Apache" -ForegroundColor White

} else {
    Write-Host "`n  [WARN] SQL Server drivers niet gevonden" -ForegroundColor Yellow
    Write-Host "`n  Download en installeer de Microsoft SQL Server drivers:" -ForegroundColor Cyan
    Write-Host "  1. Download drivers van:" -ForegroundColor White
    Write-Host "     https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server" -ForegroundColor Gray
    Write-Host "`n  2. Of gebruik direct link voor PHP $PhpVersionShort (Windows x64):" -ForegroundColor White

    # Bepaal de juiste download link
    if ($PhpVersionShort -eq "8.3") {
        Write-Host "     https://go.microsoft.com/fwlink/?linkid=2249004" -ForegroundColor Cyan
    } elseif ($PhpVersionShort -eq "8.2") {
        Write-Host "     https://go.microsoft.com/fwlink/?linkid=2249004" -ForegroundColor Cyan
    } elseif ($PhpVersionShort -eq "8.1") {
        Write-Host "     https://go.microsoft.com/fwlink/?linkid=2249004" -ForegroundColor Cyan
    } else {
        Write-Host "     https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server" -ForegroundColor Cyan
    }

    Write-Host "`n  3. Pak het ZIP bestand uit" -ForegroundColor White
    Write-Host "  4. Kopieer de juiste DLL's naar: $PhpExtDir" -ForegroundColor White
    Write-Host "     Voor PHP $PhpVersionShort x64 Thread Safe gebruik:" -ForegroundColor Gray
    Write-Host "     - php_sqlsrv_$($PhpVersionShort -replace '\.','')_ts_x64.dll -> php_sqlsrv.dll" -ForegroundColor Gray
    Write-Host "     - php_pdo_sqlsrv_$($PhpVersionShort -replace '\.','')_ts_x64.dll -> php_pdo_sqlsrv.dll" -ForegroundColor Gray
    Write-Host "`n  5. Voeg toe aan php.ini:" -ForegroundColor White
    Write-Host "     extension=sqlsrv" -ForegroundColor Gray
    Write-Host "     extension=pdo_sqlsrv" -ForegroundColor Gray
    Write-Host "`n  6. Installeer Microsoft Visual C++ Redistributable:" -ForegroundColor White
    Write-Host "     https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Cyan
    Write-Host "`n  7. Herstart Apache" -ForegroundColor White
}

# Check Visual C++ Redistributable
Write-Host "`n[BONUS] Microsoft Visual C++ Redistributable Check..." -ForegroundColor Yellow
$VCRedist = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" -ErrorAction SilentlyContinue
if ($VCRedist) {
    Write-Host "  [OK] Visual C++ Redistributable geïnstalleerd" -ForegroundColor Green
    Write-Host "  [INFO] Versie: $($VCRedist.Version)" -ForegroundColor Gray
} else {
    Write-Host "  [WARN] Visual C++ Redistributable niet gedetecteerd" -ForegroundColor Yellow
    Write-Host "  [INFO] SQL Server drivers hebben deze nodig om te werken" -ForegroundColor Gray
    Write-Host "  Download: https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Cyan
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Diagnose Voltooid" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

Write-Host "`nTest de connectie met dit PHP script:" -ForegroundColor Cyan
Write-Host @"
<?php
`$serverName = "localhost\SQLEXPRESS"; // Of je SQL Server naam
`$connectionOptions = array(
    "Database" => "testdb",
    "Uid" => "sa",
    "PWD" => "password"
);

// Test met sqlsrv
`$conn = sqlsrv_connect(`$serverName, `$connectionOptions);
if (`$conn) {
    echo "Connectie met sqlsrv: OK\n";
    sqlsrv_close(`$conn);
} else {
    echo "Connectie met sqlsrv: FAILED\n";
    print_r(sqlsrv_errors());
}

// Test met PDO
try {
    `$pdo = new PDO("sqlsrv:Server=`$serverName;Database=testdb", "sa", "password");
    echo "Connectie met PDO: OK\n";
} catch (PDOException `$e) {
    echo "Connectie met PDO: FAILED - " . `$e->getMessage() . "\n";
}
?>
"@ -ForegroundColor Gray

Write-Host "`nDruk op een toets om af te sluiten..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
