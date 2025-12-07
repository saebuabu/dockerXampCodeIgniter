# Docker Setup voor CodeIgniter Development

Deze Docker setup biedt een complete ontwikkelomgeving voor CodeIgniter 4 met Apache, PHP en alle benodigde extensies. De SQL Server database draait lokaal op je machine.

## Vereisten

- [Docker Desktop voor Windows](https://www.docker.com/products/docker-desktop) geïnstalleerd
- SQL Server draait lokaal op je machine
- Git (optioneel)

## Wat zit er in deze setup?

- **PHP 8.2** met Apache
- **Composer** voor package management
- **Xdebug 3** voor debugging
- **SQL Server drivers** (sqlsrv & pdo_sqlsrv)
- **Alle vereiste PHP extensies**: mbstring, intl, openssl, json, curl, pdo

## Projectstructuur

```
ExamenXampDocker/
├── docker/
│   └── php/
│       └── php.ini          # PHP configuratie
├── public/                  # CodeIgniter public folder (indien aanwezig)
├── app/                     # CodeIgniter applicatie
├── .env                     # Jouw database configuratie
├── .env.example             # Voorbeeld configuratie
├── docker-compose.yml       # Docker services definitie
├── Dockerfile               # PHP/Apache container definitie
└── DOCKER_SETUP.md          # Deze handleiding
```

## Installatie & Setup

### 1. Kopieer de environment file

```bash
cp .env.example .env
```

### 2. Pas de database configuratie aan

Open `.env` en pas de database gegevens aan:

```ini
database.default.hostname = host.docker.internal  # Blijf dit zo!
database.default.database = jouw_database_naam
database.default.username = jouw_gebruikersnaam
database.default.password = jouw_wachtwoord
```

**Belangrijk:** Gebruik `host.docker.internal` als hostname. Dit is het speciale adres waarmee Docker containers kunnen verbinden met services op je lokale machine.

### 3. Controleer SQL Server toegang

Zorg dat SQL Server luistert op TCP/IP:

1. Open **SQL Server Configuration Manager**
2. Ga naar **SQL Server Network Configuration → Protocols**
3. Schakel **TCP/IP** in
4. Herstart de SQL Server service

Controleer dat SQL Server Authentication is ingeschakeld als je geen Windows Authentication gebruikt.

### 4. Build en start de containers

```bash
docker-compose up --build
```

Bij de eerste keer duurt dit langer (5-10 minuten) omdat alle dependencies worden gedownload en geïnstalleerd.

### 5. Installeer CodeIgniter (indien nog niet gedaan)

Als je nog geen CodeIgniter project hebt:

```bash
docker-compose exec web composer create-project codeigniter4/appstarter .
```

Of installeer dependencies van een bestaand project:

```bash
docker-compose exec web composer install
```

## Gebruik

### De applicatie draaien

```bash
# Start containers
docker-compose up

# Start in de achtergrond
docker-compose up -d

# Stop containers
docker-compose down
```

### Toegang tot de applicatie

- **URL:** http://localhost:8080
- **Xdebug Port:** 9003

### Composer commando's uitvoeren

```bash
# Composer install
docker-compose exec web composer install

# Composer update
docker-compose exec web composer update

# Package toevoegen
docker-compose exec web composer require package/name
```

### In de container werken

```bash
# Open een bash shell in de container
docker-compose exec web bash

# Voer een PHP commando uit
docker-compose exec web php spark migrate
```

### Logs bekijken

```bash
# Alle logs
docker-compose logs

# Specifieke service
docker-compose logs web

# Live logs volgen
docker-compose logs -f web
```

## Debugging met Xdebug

### VS Code configuratie

Maak `.vscode/launch.json` aan:

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
                "/var/www/html": "${workspaceFolder}"
            }
        }
    ]
}
```

### Debugging starten

1. Installeer de **PHP Debug** extensie in VS Code
2. Zet breakpoints in je code
3. Start debugging (F5 of via Run → Start Debugging)
4. Laad de pagina in je browser
5. VS Code pauzeert bij je breakpoints

## Database verbinding testen

Maak een test PHP bestand `test-db.php` in de root:

```php
<?php
$serverName = "host.docker.internal";
$connectionOptions = [
    "Database" => "jouw_database",
    "Uid" => "jouw_gebruiker",
    "PWD" => "jouw_wachtwoord",
    "TrustServerCertificate" => true
];

$conn = sqlsrv_connect($serverName, $connectionOptions);

if ($conn) {
    echo "Verbinding gelukt!";
    sqlsrv_close($conn);
} else {
    echo "Verbinding mislukt:<br>";
    print_r(sqlsrv_errors());
}
```

Test via: http://localhost:8080/test-db.php

## Troubleshooting

### Container start niet

```bash
# Bekijk logs
docker-compose logs web

# Rebuild zonder cache
docker-compose build --no-cache
docker-compose up
```

### Database verbinding mislukt

**Fout:** "Cannot connect to host.docker.internal"

**Oplossingen:**
1. Controleer of SQL Server draait op je machine
2. Controleer of TCP/IP is ingeschakeld in SQL Server Configuration Manager
3. Controleer Windows Firewall instellingen
4. Test de verbinding met SSMS vanuit je host machine

**Fout:** "Login failed for user"

**Oplossingen:**
1. Controleer username en password in `.env`
2. Zorg dat SQL Server Authentication is ingeschakeld
3. Controleer of de gebruiker toegang heeft tot de database

### Xdebug werkt niet

1. Controleer of de PHP Debug extensie is geïnstalleerd in VS Code
2. Controleer `launch.json` configuratie
3. Bekijk Xdebug logs:
   ```bash
   docker-compose exec web cat /tmp/xdebug.log
   ```

### Port 8080 is al in gebruik

Wijzig de port in `docker-compose.yml`:

```yaml
ports:
  - "8081:80"  # Gebruik 8081 in plaats van 8080
```

### Permissie problemen

```bash
# Geef de juiste permissies
docker-compose exec web chown -R www-data:www-data /var/www/html
```

## Handige commando's

```bash
# Container status bekijken
docker-compose ps

# Resource gebruik bekijken
docker stats

# Container opnieuw builden
docker-compose build

# Oude images opruimen
docker system prune -a

# Alleen de database van de container leegmaken (niet de code!)
docker-compose down -v
```

## Development workflow

1. **Start containers:** `docker-compose up -d`
2. **Bewerk code** in je editor (VS Code)
3. **Wijzigingen zijn direct zichtbaar** (geen rebuild nodig door volume mount)
4. **Debug indien nodig** met Xdebug
5. **Run tests:** `docker-compose exec web php spark test`
6. **Stop containers:** `docker-compose down`

## Productie

**Waarschuwing:** Deze setup is ALLEEN voor development!

Voor productie:
- Verwijder Xdebug
- Gebruik productie PHP settings
- Voeg geen `.env` toe aan Git
- Gebruik environment variables voor gevoelige data
- Overweeg een reverse proxy (nginx)

## Meer informatie

- [Docker Documentation](https://docs.docker.com/)
- [CodeIgniter 4 Documentation](https://codeigniter.com/user_guide/)
- [Xdebug Documentation](https://xdebug.org/docs/)
- [PHP Docker Images](https://hub.docker.com/_/php)
