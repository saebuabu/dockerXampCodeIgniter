# Windows 10 VM Installatie Handleiding

Deze handleiding helpt je om de ontwikkelstack op een Windows 10 virtuele machine te installeren zonder Docker te gebruiken.

## Vereisten

- Windows 10 virtuele machine
- Minimaal 8GB RAM
- 20GB vrije schijfruimte
- Administrator rechten

## Snelle Installatie

### Stap 1: Download het project

Als je het project nog niet hebt gedownload:

```powershell
cd C:\Users\<YourUsername>\source\repos
git clone <repository-url> ExamenXampDocker
cd ExamenXampDocker
```

### Stap 2: Run het installatiescript

1. Open **PowerShell als Administrator**:
   - Klik rechts op Windows Start knop
   - Selecteer "Windows PowerShell (Admin)"

2. Navigeer naar de project directory:
   ```powershell
   cd C:\Users\P99900086\source\repos\ExamenXampDocker
   ```

3. Zet de execution policy tijdelijk aan:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```

4. Run het installatiescript:
   ```powershell
   .\windows-setup.ps1
   ```

5. Volg de instructies op het scherm

Het script zal automatisch het volgende installeren:
- XAMPP (Apache + PHP 8.2)
- Composer
- Git
- SQL Server Express (optioneel)
- SQL Server Management Studio (optioneel)
- Visual Studio Code (optioneel)
- PHP SQL Server drivers
- Xdebug

## Na de Installatie

### 1. Start XAMPP

1. Open XAMPP Control Panel: `C:\xampp\xampp-control.exe`
2. Start de **Apache** service
3. (Optioneel) Start **MySQL** als je een lokale MySQL database wilt

### 2. Configureer Database Connectie

Bewerk `C:\xampp\htdocs\ExamenXampDocker\app\Config\Database.php`:

#### Voor SQL Server Express (lokaal):

```php
public array $default = [
    'DSN'          => '',
    'hostname'     => 'localhost\SQLEXPRESS',
    'username'     => 'sa',
    'password'     => 'YourStrong!Password123',
    'database'     => 'your_database_name',
    'DBDriver'     => 'SQLSRV',
    'DBPrefix'     => '',
    'pConnect'     => false,
    'DBDebug'      => true,
    'charset'      => 'utf8',
    'DBCollat'     => 'utf8_general_ci',
    'swapPre'      => '',
    'encrypt'      => false,
    'compress'     => false,
    'strictOn'     => false,
    'failover'     => [],
    'port'         => 1433,
];
```

#### Voor schoolserver:

```php
public array $default = [
    'DSN'          => '',
    'hostname'     => 'school-server-address',
    'username'     => 'your_username',
    'password'     => 'your_password',
    'database'     => 'your_database_name',
    'DBDriver'     => 'SQLSRV',
    'DBPrefix'     => '',
    'pConnect'     => false,
    'DBDebug'      => true,
    'charset'      => 'utf8',
    'DBCollat'     => 'utf8_general_ci',
    'swapPre'      => '',
    'encrypt'      => true,
    'compress'     => false,
    'strictOn'     => false,
    'failover'     => [],
    'port'         => 1433,
];
```

### 3. Test de Installatie

1. Open je browser
2. Ga naar: `http://localhost/`
3. Je zou de CodeIgniter welcome page moeten zien

### 4. Visual Studio Code Setup

#### Installeer extensies:

Open VS Code en installeer:
- **PHP Intelephense** (bmewburn.vscode-intelephense-client)
- **PHP Debug** (xdebug.php-debug)
- **CodeIgniter 4 Snippets** (optioneel)

#### Configureer Debugging:

Maak `.vscode/launch.json` in je project:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "C:/xampp/htdocs/ExamenXampDocker": "${workspaceFolder}"
            },
            "log": true,
            "xdebugSettings": {
                "max_data": 65535,
                "show_hidden": 1,
                "max_children": 100,
                "max_depth": 5
            }
        },
        {
            "name": "Launch currently open script",
            "type": "php",
            "request": "launch",
            "program": "${file}",
            "cwd": "${fileDirname}",
            "port": 9003
        }
    ]
}
```

### 5. Test Xdebug

1. Open een PHP bestand in VS Code
2. Zet een breakpoint (klik links van een regel nummer)
3. Druk op F5 of start debugging via menu
4. Refresh je browser met de applicatie
5. VS Code zou moeten stoppen bij je breakpoint

## Handmatige Installatie (als het script niet werkt)

### XAMPP

1. Download van: https://www.apachefriends.org/
2. Kies versie 8.2.x
3. Installeer naar `C:\xampp`

### Composer

1. Download van: https://getcomposer.org/download/
2. Run installer
3. Kies PHP executable: `C:\xampp\php\php.exe`

### Git

1. Download van: https://git-scm.com/download/win
2. Installeer met default opties

### SQL Server Drivers

1. Download Microsoft ODBC Driver 18:
   - https://go.microsoft.com/fwlink/?linkid=2249004

2. Download PHP SQL Server drivers:
   - https://github.com/microsoft/msphpsql/releases/latest
   - Download `Windows-8.2.zip`
   - Extract en kopieer naar `C:\xampp\php\ext\`:
     - `php_sqlsrv_82_ts_x64.dll` → `php_sqlsrv.dll`
     - `php_pdo_sqlsrv_82_ts_x64.dll` → `php_pdo_sqlsrv.dll`

3. Pas `C:\xampp\php\php.ini` aan:
   ```ini
   extension=sqlsrv
   extension=pdo_sqlsrv
   ```

### Xdebug

1. Download van: https://xdebug.org/download
2. Kies: `PHP 8.2 VS16 TS (64 bit)`
3. Kopieer naar: `C:\xampp\php\ext\php_xdebug.dll`
4. Voeg toe aan `php.ini`:
   ```ini
   [xdebug]
   zend_extension=xdebug
   xdebug.mode=develop,debug
   xdebug.start_with_request=yes
   xdebug.client_host=127.0.0.1
   xdebug.client_port=9003
   xdebug.log=C:\xampp\tmp\xdebug.log
   xdebug.idekey=VSCODE
   ```

## Veelvoorkomende Problemen

### Apache start niet

**Probleem**: Poort 80 is al in gebruik

**Oplossing**:
1. Open `C:\xampp\apache\conf\httpd.conf`
2. Zoek: `Listen 80`
3. Verander naar: `Listen 8080`
4. Herstart Apache
5. Open browser: `http://localhost:8080`

### SQL Server connectie mislukt

**Probleem**: "Could not connect to database"

**Checklist**:
- [ ] SQL Server service draait (check services.msc)
- [ ] ODBC Driver 18 geinstalleerd
- [ ] PHP extensies geladen (`php -m` in command prompt)
- [ ] Juiste hostname/username/password in Database.php
- [ ] Firewall staat verbinding toe

**Test SQL Server connectie**:
```powershell
sqlcmd -S localhost\SQLEXPRESS -U sa -P YourStrong!Password123
```

### Xdebug werkt niet

**Checklist**:
- [ ] Xdebug extensie geladen: `php -v` (moet Xdebug info tonen)
- [ ] Poort 9003 niet geblokkeerd door firewall
- [ ] VS Code PHP Debug extensie geinstalleerd
- [ ] launch.json correct geconfigureerd

**Test Xdebug**:
```php
<?php
phpinfo();
// Zoek naar "xdebug" in de output
```

### Composer werkt niet

**Probleem**: "composer: command not found"

**Oplossing**:
```powershell
# Herstart PowerShell of voeg toe aan PATH:
$env:Path += ";C:\ProgramData\ComposerSetup\bin"

# Of gebruik volledige pad:
& "C:\ProgramData\ComposerSetup\bin\composer.bat" install
```

## Prestatie Tips

1. **Disable Windows Defender scanning voor:**
   - `C:\xampp`
   - Je project directory

2. **Apache Performance** - Edit `C:\xampp\apache\conf\httpd.conf`:
   ```apache
   EnableMMAP off
   EnableSendfile off
   ```

3. **PHP OPcache** - In `php.ini`:
   ```ini
   [opcache]
   opcache.enable=1
   opcache.memory_consumption=128
   opcache.max_accelerated_files=10000
   ```

## Ontwikkel Workflow

1. **Code in VS Code**:
   ```powershell
   cd C:\xampp\htdocs\ExamenXampDocker
   code .
   ```

2. **Run development server** (alternatief voor Apache):
   ```powershell
   php spark serve
   ```
   Open: `http://localhost:8080`

3. **Database migraties**:
   ```powershell
   php spark migrate
   ```

4. **Maak nieuwe controller**:
   ```powershell
   php spark make:controller YourController
   ```

## Nuttige Commands

```powershell
# Check PHP versie en extensies
php -v
php -m

# Check Apache status
netstat -ano | findstr :80

# CodeIgniter commands
php spark list
php spark serve
php spark migrate
php spark db:seed YourSeeder

# Composer
composer install
composer update
composer require vendor/package

# Git
git status
git add .
git commit -m "message"
git push
```

## Backup & Restore

### Backup project:
```powershell
# Code
git commit -am "Backup $(Get-Date -Format 'yyyy-MM-dd')"
git push

# Database
sqlcmd -S localhost\SQLEXPRESS -d your_database -Q "BACKUP DATABASE your_database TO DISK='C:\backup\db.bak'"
```

### Restore database:
```powershell
sqlcmd -S localhost\SQLEXPRESS -Q "RESTORE DATABASE your_database FROM DISK='C:\backup\db.bak' WITH REPLACE"
```

## Referenties

- [CodeIgniter 4 Docs](https://codeigniter.com/user_guide/)
- [XAMPP Docs](https://www.apachefriends.org/docs/)
- [PHP.net](https://www.php.net/)
- [Xdebug Docs](https://xdebug.org/docs/)
- [SQL Server Docs](https://learn.microsoft.com/sql/)

## Support

Voor problemen of vragen:
1. Check de log file: `installation-log.txt`
2. Check PHP errors: `C:\xampp\php\logs\php_error_log`
3. Check Apache errors: `C:\xampp\apache\logs\error.log`
