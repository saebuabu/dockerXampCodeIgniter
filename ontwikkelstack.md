# Ontwikkelstack

## 1. Basisomgeving

### Besturingssysteem
- Windows 10/11

### XAMPP
**Apache webserver** met PHP

#### PHP-versie
- Geschikte versie voor de gebruikte CodeIgniter-versie

#### Benodigde PHP-extensies
- `mbstring`
- `intl`
- `openssl`
- `json`
- `curl`
- `pdo`
- `sqlsrv` / `pdo_sqlsrv` (voor koppeling met MS SQL)

### Composer
- Composer geïnstalleerd op de ontwikkelmachine
- Gebruik van Composer voor installatie en beheer van CodeIgniter en benodigde PHP-packages

## 2. Database

- **Microsoft SQL Server** (lokaal of via schoolserver)
- **SQL Server Management Studio (SSMS)** voor beheer

## 3. CodeIgniter

- Werkende CodeIgniter-installatie (bij voorkeur **CodeIgniter 4**)
- Project draait lokaal via XAMPP
- Configuratie voor de database-verbinding met MS SQL via de SQLSRV-driver

## 4. Tools & Versiebeheer

### Visual Studio Code
Code-editor met de volgende extensies:
- PHP-extensie (IntelliSense)
- Debug-extensie voor PHP (Xdebug)

### Git
Lokaal versiebeheer:
- Lokale repository voor het examenproject
- Basisgebruik van commits (met duidelijke berichten)

## 5. Debugging

- **Xdebug** geïnstalleerd en geactiveerd in `php.ini`
- Debugconfiguratie in VS Code voor gebruik van breakpoints in PHP/CodeIgniter-code
