# CodeIgniter 4 Application Starter

## Snelle Setup voor VM (Windows + XAMPP)

### Vereisten
1. XAMPP geïnstalleerd (Apache + PHP + MySQL)
2. Composer geïnstalleerd ([Download hier](https://getcomposer.org/download/))
3. PowerShell met execution policy ingesteld (zie hieronder)

### PowerShell Execution Policy instellen
Open PowerShell als Administrator:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Installatie Stappen

**Optie 1: Automatisch (Aanbevolen)**
1. Clone dit project naar je lokale machine
2. Run het installatie script als Administrator:
   ```powershell
   .\fix-apache-config.ps1
   ```
3. Start Apache via XAMPP Control Panel
4. Open browser: `http://localhost/Examen/`

**Optie 2: Handmatig**
1. Clone of kopieer project naar `C:\xampp\htdocs\Examen`
2. Installeer dependencies:
   ```bash
   cd C:\xampp\htdocs\Examen
   composer install
   ```
3. Start Apache via XAMPP Control Panel
4. Open browser: `http://localhost/Examen/`

### Troubleshooting

**Probleem: "Failed to open stream: No such file or directory" (vendor/codeigniter4/framework/system/Boot.php)**

De Composer dependencies zijn niet geïnstalleerd. Los dit op met:
```powershell
.\install-dependencies.ps1
```

Of handmatig:
```bash
cd C:\xampp\htdocs\Examen
composer install
```

**Probleem: Apache start niet**

Controleer of poort 80 en 443 beschikbaar zijn. Stop eventuele andere webservers (IIS, andere Apache instanties).

**Probleem: SQL Server drivers niet geladen of DLL's niet gevonden**

Als je met Microsoft SQL Server werkt en de drivers zijn niet correct geladen:
```powershell
.\fix-sqlsrv-drivers.ps1
```

Dit script zal:
- Detecteren welke PHP versie je hebt
- Controleren of de drivers al geladen zijn
- Instructies geven voor het downloaden van de juiste drivers
- Verifiëren of Visual C++ Redistributable geïnstalleerd is

Handmatige installatie:
1. Download Microsoft Drivers voor PHP voor SQL Server van [Microsoft](https://learn.microsoft.com/en-us/sql/connect/php/download-drivers-php-sql-server)
2. Pak het ZIP bestand uit en kopieer de juiste DLL's naar `C:\xampp\php\ext`
3. Voeg toe aan `php.ini`:
   ```ini
   extension=sqlsrv
   extension=pdo_sqlsrv
   ```
4. Installeer [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)
5. Herstart Apache

---

## What is CodeIgniter?

CodeIgniter is a PHP full-stack web framework that is light, fast, flexible and secure.
More information can be found at the [official site](https://codeigniter.com).

This repository holds a composer-installable app starter.
It has been built from the
[development repository](https://github.com/codeigniter4/CodeIgniter4).

More information about the plans for version 4 can be found in [CodeIgniter 4](https://forum.codeigniter.com/forumdisplay.php?fid=28) on the forums.

You can read the [user guide](https://codeigniter.com/user_guide/)
corresponding to the latest version of the framework.

## Installation & updates

`composer create-project codeigniter4/appstarter` then `composer update` whenever
there is a new release of the framework.

When updating, check the release notes to see if there are any changes you might need to apply
to your `app` folder. The affected files can be copied or merged from
`vendor/codeigniter4/framework/app`.

## Setup

Copy `env` to `.env` and tailor for your app, specifically the baseURL
and any database settings.

## Important Change with index.php

`index.php` is no longer in the root of the project! It has been moved inside the *public* folder,
for better security and separation of components.

This means that you should configure your web server to "point" to your project's *public* folder, and
not to the project root. A better practice would be to configure a virtual host to point there. A poor practice would be to point your web server to the project root and expect to enter *public/...*, as the rest of your logic and the
framework are exposed.

**Please** read the user guide for a better explanation of how CI4 works!

## Repository Management

We use GitHub issues, in our main repository, to track **BUGS** and to track approved **DEVELOPMENT** work packages.
We use our [forum](http://forum.codeigniter.com) to provide SUPPORT and to discuss
FEATURE REQUESTS.

This repository is a "distribution" one, built by our release preparation script.
Problems with it can be raised on our forum, or as issues in the main repository.

## Server Requirements

PHP version 8.1 or higher is required, with the following extensions installed:

- [intl](http://php.net/manual/en/intl.requirements.php)
- [mbstring](http://php.net/manual/en/mbstring.installation.php)

> [!WARNING]
> - The end of life date for PHP 7.4 was November 28, 2022.
> - The end of life date for PHP 8.0 was November 26, 2023.
> - If you are still using PHP 7.4 or 8.0, you should upgrade immediately.
> - The end of life date for PHP 8.1 will be December 31, 2025.

Additionally, make sure that the following extensions are enabled in your PHP:

- json (enabled by default - don't turn it off)
- [mysqlnd](http://php.net/manual/en/mysqlnd.install.php) if you plan to use MySQL
- [libcurl](http://php.net/manual/en/curl.requirements.php) if you plan to use the HTTP\CURLRequest library
