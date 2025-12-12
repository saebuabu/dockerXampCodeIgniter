# Installeer CodeIgniter Dependencies
# Run dit script als Composer dependencies ontbreken

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Composer Dependencies Installeren" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$HtdocsPath = "C:\xampp\htdocs\Examen"

# Check of project bestaat
if (-not (Test-Path $HtdocsPath)) {
    Write-Host "`n[FAIL] Project niet gevonden in: $HtdocsPath" -ForegroundColor Red
    Write-Host "Run eerst fix-apache-config.ps1" -ForegroundColor Yellow
    pause
    exit 1
}

# Check of composer.json bestaat
if (-not (Test-Path "$HtdocsPath\composer.json")) {
    Write-Host "`n[FAIL] composer.json niet gevonden in: $HtdocsPath" -ForegroundColor Red
    pause
    exit 1
}

# Check of Composer geinstalleerd is
$ComposerCmd = Get-Command composer -ErrorAction SilentlyContinue
if (-not $ComposerCmd) {
    Write-Host "`n[FAIL] Composer niet gevonden" -ForegroundColor Red
    Write-Host "`nInstalleer Composer vanaf: https://getcomposer.org/download/" -ForegroundColor Yellow
    Write-Host "Na installatie, herstart PowerShell en run dit script opnieuw" -ForegroundColor Yellow
    pause
    exit 1
}

# Installeer dependencies
Write-Host "`n[1/2] Installeren Composer dependencies..." -ForegroundColor Yellow
Write-Host "  Dit kan enkele minuten duren..." -ForegroundColor Gray

try {
    Set-Location $HtdocsPath
    & composer install --no-dev --optimize-autoloader

    # Verificeer installatie
    Write-Host "`n[2/2] Verificeren installatie..." -ForegroundColor Yellow
    if (Test-Path "$HtdocsPath\vendor\codeigniter4\framework\system\Boot.php") {
        Write-Host "  [OK] CodeIgniter framework gevonden" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] CodeIgniter framework niet gevonden" -ForegroundColor Red
        exit 1
    }

    if (Test-Path "$HtdocsPath\vendor\autoload.php") {
        Write-Host "  [OK] Composer autoloader gevonden" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Composer autoloader niet gevonden" -ForegroundColor Red
        exit 1
    }

    Write-Host "`n=====================================" -ForegroundColor Green
    Write-Host "  Installatie Succesvol!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "`nJe kunt nu Apache starten via XAMPP Control Panel" -ForegroundColor Cyan
    Write-Host "Open browser: http://localhost/Examen/" -ForegroundColor White

} catch {
    Write-Host "`n[FAIL] Installatie mislukt: $_" -ForegroundColor Red
    Write-Host "`nProbeer handmatig:" -ForegroundColor Yellow
    Write-Host "  cd $HtdocsPath" -ForegroundColor White
    Write-Host "  composer install" -ForegroundColor White
    exit 1
}

Write-Host "`nDruk op een toets om af te sluiten..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
