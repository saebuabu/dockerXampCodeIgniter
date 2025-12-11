# Quick Fix voor Apache Configuratie Probleem
# Run dit script als Administrator op je virtuele machine

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Apache Configuratie Fix" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$ProjectRoot = $PSScriptRoot
$HtdocsPath = "C:\xampp\htdocs\Examen"

# Stap 1: Check of CodeIgniter project bestaat in source
Write-Host "`n[1/3] Controleren project source..." -ForegroundColor Yellow
if ((Test-Path "$ProjectRoot\app") -and (Test-Path "$ProjectRoot\public")) {
    Write-Host "  [OK] CodeIgniter project gevonden in: $ProjectRoot" -ForegroundColor Green

    # Stap 2: Kopieer project naar htdocs
    Write-Host "`n[2/3] Kopieren CodeIgniter project..." -ForegroundColor Yellow

    # Verwijder oude incomplete installatie
    if (Test-Path $HtdocsPath) {
        Write-Host "  Verwijderen oude installatie..." -ForegroundColor Gray
        Remove-Item $HtdocsPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    try {
        Write-Host "  Kopieren project..." -ForegroundColor Gray
        Copy-Item -Path $ProjectRoot -Destination "C:\xampp\htdocs\" -Recurse -Force

        # Hernoem als nodig
        if (Test-Path "C:\xampp\htdocs\ExamenXampDocker") {
            Rename-Item "C:\xampp\htdocs\ExamenXampDocker" "Examen"
        }

        Write-Host "  [OK] Project gekopieerd naar: $HtdocsPath" -ForegroundColor Green

        # Verificeer belangrijke directories
        if ((Test-Path "$HtdocsPath\app") -and (Test-Path "$HtdocsPath\public")) {
            Write-Host "  [OK] app en public directories gevonden" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] app of public directory ontbreekt" -ForegroundColor Red
            exit 1
        }

    } catch {
        Write-Host "  [FAIL] Kopieren mislukt: $_" -ForegroundColor Red
        exit 1
    }

} else {
    Write-Host "  [FAIL] CodeIgniter project niet gevonden in: $ProjectRoot" -ForegroundColor Red
    Write-Host "`n  Zorg dat je dit script runt vanuit de project directory die app/ en public/ bevat" -ForegroundColor Yellow
    exit 1
}

# Stap 3: Test Apache configuratie
Write-Host "`n[3/3] Testen Apache configuratie..." -ForegroundColor Yellow
$ApacheExe = "C:\xampp\apache\bin\httpd.exe"
if (Test-Path $ApacheExe) {
    $ApacheTest = & $ApacheExe -t 2>&1

    if ($ApacheTest -match "Syntax OK") {
        Write-Host "  [OK] Apache configuratie is correct!" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Apache configuratie waarschuwingen:" -ForegroundColor Yellow
        $ApacheTest | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
} else {
    Write-Host "  [SKIP] Apache executable niet gevonden" -ForegroundColor Gray
}

# Samenvatting
Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Fix Voltooid!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nVolgende stappen:" -ForegroundColor Cyan
Write-Host "1. Start Apache via XAMPP Control Panel" -ForegroundColor White
Write-Host "2. Open browser: http://localhost/" -ForegroundColor White
Write-Host "3. Open CodeIgniter: http://localhost/Examen/" -ForegroundColor White
Write-Host "`nDruk op een toets om af te sluiten..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
