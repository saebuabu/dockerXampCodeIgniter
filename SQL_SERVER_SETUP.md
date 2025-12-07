# SQL Server Setup voor Docker Development

Deze handleiding beschrijft alle stappen die nodig zijn om SQL Server te configureren voor gebruik met de Docker development omgeving.

## Inhoudsopgave

1. [Mixed Mode Authentication inschakelen](#1-mixed-mode-authentication-inschakelen)
2. [SQL Server gebruiker aanmaken](#2-sql-server-gebruiker-aanmaken)
3. [Rechten toekennen](#3-rechten-toekennen)
4. [SQL Server service herstarten](#4-sql-server-service-herstarten)
5. [TCP/IP protocol inschakelen](#5-tcpip-protocol-inschakelen)
6. [Verificatie](#6-verificatie)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Mixed Mode Authentication inschakelen

SQL Server staat standaard op "Windows Authentication Only". Voor Docker containers moet SQL Server Authentication worden ingeschakeld.

### Stappen:

1. Open **SQL Server Management Studio (SSMS)**
2. Maak verbinding met je SQL Server instance
3. **Rechtermuisklik** op de server naam (bovenaan in Object Explorer)
4. Klik op **Properties**
5. Ga naar **Security** (linker menu)
6. Selecteer: **SQL Server and Windows Authentication mode**
7. Klik **OK**
8. **Belangrijk:** Herstart de SQL Server service! (zie stap 4)

### Verificatie via SQL:

```sql
-- Check Authentication Mode
-- Result should be 'Mixed' or 'SQL Server and Windows Authentication mode'
EXEC xp_loginconfig 'login mode';
```

---

## 2. SQL Server gebruiker aanmaken

Maak een SQL Server login aan specifiek voor de Docker container.

### SQL Script:

```sql
-- Gebruik master database voor server-level login
USE master;
GO

-- Verwijder oude login als die bestaat (optioneel, alleen bij problemen)
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'docker_user')
    DROP LOGIN docker_user;
GO

-- Maak nieuwe login aan
CREATE LOGIN docker_user
WITH PASSWORD = 'JouwSterkWachtwoord123!',
     CHECK_POLICY = OFF,
     CHECK_EXPIRATION = OFF,
     DEFAULT_DATABASE = ExamenDatabase;
GO

-- Geef CONNECT permission (belangrijk!)
GRANT CONNECT SQL TO docker_user;
GO

-- Verificatie
SELECT
    name,
    type_desc,
    is_disabled,
    create_date,
    default_database_name
FROM sys.server_principals
WHERE name = 'docker_user';
```

**Belangrijk:**
- Pas het wachtwoord aan naar een sterk wachtwoord
- Pas de database naam aan (`ExamenDatabase`) naar jouw database

---

## 3. Rechten toekennen

Geef de docker_user toegang tot de juiste database en rechten.

### SQL Script:

```sql
-- Switch naar je applicatie database
USE ExamenDatabase;
GO

-- Verwijder oude database user als die bestaat (optioneel)
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'docker_user')
    DROP USER docker_user;
GO

-- Maak database user aan
CREATE USER docker_user FOR LOGIN docker_user;
GO

-- Geef lees- en schrijfrechten
ALTER ROLE db_datareader ADD MEMBER docker_user;
ALTER ROLE db_datawriter ADD MEMBER docker_user;
GO

-- Voor meer rechten (bijv. DDL operations), voeg ook toe:
-- ALTER ROLE db_ddladmin ADD MEMBER docker_user;

-- Verificatie
SELECT
    dp.name as UserName,
    dp.type_desc as UserType,
    STRING_AGG(r.name, ', ') as Roles
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'docker_user'
GROUP BY dp.name, dp.type_desc;
```

### Uitleg van rollen:

- **db_datareader** - Kan alle data lezen uit alle tabellen
- **db_datawriter** - Kan data toevoegen, wijzigen en verwijderen
- **db_ddladmin** - Kan database schema wijzigen (CREATE, ALTER, DROP)
- **db_owner** - Volledige rechten (niet aanbevolen voor productie)

---

## 4. SQL Server service herstarten

Na het inschakelen van Mixed Mode Authentication MOET je de SQL Server service herstarten.

### Optie 1: Via SQL Server Configuration Manager (Aanbevolen)

1. Open **SQL Server Configuration Manager**
2. Klik op **SQL Server Services** (linker panel)
3. Zoek **SQL Server (MSSQLSERVER)** of je instance naam
4. **Rechtermuisklik** → **Restart**
5. Wacht tot status "Running" is

### Optie 2: Via Windows Services

1. Druk **Windows + R**
2. Typ: `services.msc`
3. Zoek **SQL Server (MSSQLSERVER)**
4. **Rechtermuisklik** → **Restart**

### Optie 3: Via Command Prompt (Als Administrator)

```cmd
net stop MSSQLSERVER
net start MSSQLSERVER
```

Voor benoemde instances:
```cmd
net stop "MSSQL$INSTANCENAAM"
net start "MSSQL$INSTANCENAAM"
```

---

## 5. TCP/IP protocol inschakelen

Docker containers verbinden via TCP/IP, dus dit protocol moet actief zijn.

### Stappen:

1. Open **SQL Server Configuration Manager**
2. Ga naar **SQL Server Network Configuration** → **Protocols for MSSQLSERVER**
3. **Rechtermuisklik** op **TCP/IP** → **Enable**
4. **Dubbelklik** op **TCP/IP**
5. Ga naar tabblad **IP Addresses**
6. Scroll naar **IPALL**
7. Controleer dat **TCP Port** is ingesteld op **1433**
8. Klik **OK**
9. **Herstart SQL Server service** (zie stap 4)

### Verificatie via SQL:

```sql
-- Check of TCP/IP enabled is
EXEC xp_readerrorlog 0, 1, N'Server is listening on';
```

---

## 6. Verificatie

Test of de configuratie correct is.

### 6.1 Verificatie in SSMS

Probeer in te loggen met SQL Server Authentication:

1. **Disconnect** van SSMS
2. Klik **Connect** → **Database Engine**
3. **Authentication:** Kies **SQL Server Authentication**
4. **Login:** `docker_user`
5. **Password:** `JouwSterkWachtwoord123!`
6. Klik **Connect**

Als dit lukt, is de SQL Server kant correct geconfigureerd.

### 6.2 Verificatie vanuit Docker

Open je browser en ga naar:

**http://localhost:8080/test-db.php**

Je zou een succesvol connectie bericht moeten zien met:
- ✓ Connection successful with sqlsrv!
- SQL Server versie informatie
- Lijst van tabellen in je database

### 6.3 Complete verificatie script

Voer dit script uit in SSMS om alles te controleren:

```sql
-- ===============================================
-- COMPLETE SQL SERVER VERIFICATIE
-- ===============================================

PRINT '========================================';
PRINT 'SQL SERVER CONFIGURATION VERIFICATION';
PRINT '========================================';
PRINT '';

-- 1. Check Authentication Mode
PRINT '1. AUTHENTICATION MODE:';
DECLARE @AuthMode INT;
EXEC xp_instance_regread
    @rootkey = 'HKEY_LOCAL_MACHINE',
    @key = 'Software\Microsoft\MSSQLServer\MSSQLServer',
    @value_name = 'LoginMode',
    @value = @AuthMode OUTPUT;

IF @AuthMode = 1
    PRINT '   ✓ Mixed Mode is ENABLED';
ELSE
    PRINT '   ✗ Windows Only - CHANGE TO MIXED MODE!';
PRINT '';

-- 2. Check if docker_user exists
PRINT '2. DOCKER_USER LOGIN:';
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'docker_user')
BEGIN
    PRINT '   ✓ Login exists';

    SELECT
        name as LoginName,
        type_desc as Type,
        is_disabled as IsDisabled,
        default_database_name as DefaultDB,
        create_date as Created
    FROM sys.server_principals
    WHERE name = 'docker_user';
END
ELSE
    PRINT '   ✗ Login does NOT exist!';
PRINT '';

-- 3. Check database access
PRINT '3. DATABASE USER:';
USE ExamenDatabase;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'docker_user')
BEGIN
    PRINT '   ✓ User exists in ExamenDatabase';

    SELECT
        dp.name as UserName,
        STRING_AGG(r.name, ', ') as Roles
    FROM sys.database_principals dp
    LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
    LEFT JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    WHERE dp.name = 'docker_user'
    GROUP BY dp.name;
END
ELSE
    PRINT '   ✗ User does NOT exist in database!';
PRINT '';

-- 4. Server info
PRINT '4. SERVER INFO:';
SELECT
    @@SERVERNAME as ServerName,
    SERVERPROPERTY('Edition') as Edition,
    SERVERPROPERTY('ProductVersion') as Version;
PRINT '';

PRINT '========================================';
PRINT 'VERIFICATION COMPLETE';
PRINT '========================================';
```

---

## 7. Troubleshooting

### Probleem: "Login failed for user 'docker_user'"

**Mogelijke oorzaken:**

1. **Mixed Mode is niet actief**
   - Controleer met: `EXEC xp_loginconfig 'login mode';`
   - Moet "Mixed" zijn, niet "Windows NT Authentication"
   - Herstart SQL Server na het wijzigen

2. **Wachtwoord klopt niet**
   - Reset het wachtwoord:
     ```sql
     ALTER LOGIN docker_user WITH PASSWORD = 'JouwSterkWachtwoord123!';
     ```
   - Controleer dat het wachtwoord in `.env` exact hetzelfde is

3. **Login is disabled**
   ```sql
   ALTER LOGIN docker_user ENABLE;
   ```

4. **CONNECT permission ontbreekt**
   ```sql
   GRANT CONNECT SQL TO docker_user;
   ```

### Probleem: "Cannot connect to server"

**Mogelijke oorzaken:**

1. **TCP/IP is niet enabled**
   - Check in SQL Server Configuration Manager
   - Enable TCP/IP protocol
   - Herstart SQL Server

2. **Windows Firewall blokkeert port 1433**
   ```powershell
   # Open PowerShell als Administrator
   New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
   ```

3. **SQL Server Browser service staat niet aan** (alleen bij benoemde instances)
   - Start de SQL Server Browser service in Services

### Probleem: "Network-related error"

**Oplossingen:**

1. Controleer of SQL Server draait:
   ```sql
   -- In SSMS
   SELECT @@SERVERNAME;
   ```

2. Test connectie vanuit Docker container:
   ```bash
   docker-compose exec web bash -c "/opt/mssql-tools18/bin/sqlcmd -S host.docker.internal -U docker_user -P 'JouwSterkWachtwoord123!' -C -Q 'SELECT 1'"
   ```

3. Controleer of `host.docker.internal` werkt:
   ```bash
   docker-compose exec web ping host.docker.internal
   ```

### Probleem: "Database does not exist"

Maak de database aan:

```sql
CREATE DATABASE ExamenDatabase;
GO

-- Geef docker_user toegang (zie stap 3)
```

---

## Samenvatting: Complete setup in één script

Als je alles opnieuw wilt instellen:

```sql
-- ===============================================
-- COMPLETE SQL SERVER SETUP VOOR DOCKER
-- ===============================================

-- 1. Server-level login aanmaken
USE master;
GO

-- Cleanup (optioneel)
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'docker_user')
    DROP LOGIN docker_user;
GO

-- Create login
CREATE LOGIN docker_user
WITH PASSWORD = 'JouwSterkWachtwoord123!',
     CHECK_POLICY = OFF,
     CHECK_EXPIRATION = OFF,
     DEFAULT_DATABASE = ExamenDatabase;
GO

GRANT CONNECT SQL TO docker_user;
GO

-- 2. Database-level user aanmaken
USE ExamenDatabase;
GO

-- Cleanup (optioneel)
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'docker_user')
    DROP USER docker_user;
GO

-- Create user and grant permissions
CREATE USER docker_user FOR LOGIN docker_user;
GO

ALTER ROLE db_datareader ADD MEMBER docker_user;
ALTER ROLE db_datawriter ADD MEMBER docker_user;
GO

-- 3. Verificatie
PRINT 'Setup complete!';
SELECT 'Login created' as Status;
SELECT name, is_disabled FROM sys.server_principals WHERE name = 'docker_user';
GO
```

**Vergeet niet:**
1. Mixed Mode Authentication in te schakelen (Properties → Security)
2. TCP/IP protocol te enablen (Configuration Manager)
3. SQL Server service te herstarten na deze wijzigingen

---

## Configuratie overzicht

### Voor Docker (.env bestand)

```ini
database.default.hostname = host.docker.internal
database.default.database = ExamenDatabase
database.default.username = docker_user
database.default.password = JouwSterkWachtwoord123!
database.default.DBDriver = SQLSRV
database.default.port = 1433
database.default.encrypt = false
database.default.trustServerCertificate = true
```

### Connection string voorbeeld

```
Server=host.docker.internal;Database=ExamenDatabase;Uid=docker_user;Pwd=JouwSterkWachtwoord123!;TrustServerCertificate=true;Encrypt=false
```

---

## Beveiligingstips

### Development:
- ✅ Gebruik een specifieke gebruiker met beperkte rechten
- ✅ Gebruik sterke wachtwoorden
- ✅ Voeg `.env` toe aan `.gitignore`

### Productie:
- ⚠️ Gebruik nooit `CHECK_POLICY = OFF` in productie
- ⚠️ Gebruik nooit `db_owner` role tenzij absoluut noodzakelijk
- ⚠️ Gebruik environment variables of Azure Key Vault voor credentials
- ⚠️ Enable encryption (`Encrypt=true`)
- ⚠️ Gebruik firewall rules om toegang te beperken

---

**Laatste update:** 2025-11-12
**SQL Server versie:** 2019 Enterprise Edition
**Docker setup:** PHP 8.2 met CodeIgniter 4.6.3
