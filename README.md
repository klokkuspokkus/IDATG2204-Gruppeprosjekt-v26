# IDATG2204 – Incident Management Dashboard

Flask-webapplikasjon som kjører som en Docker-container og kobler seg til
din XAMPP MariaDB-database.

---

## Forutsetninger

| Krav | Versjon |
|------|---------|
| Docker + Docker Compose | ≥ 24 |
| XAMPP med MariaDB kjørende | — |
| Database `idatg2204_prosjekt` importert | — |

---

## 1. Forbered XAMPP

XAMPP-databasen **må lytte på alle grensesnitt** (ikke bare localhost) slik at
Docker-containeren kan nå den.

1. Åpne `C:\xampp\mysql\bin\my.ini` (Windows) eller `/opt/lampp/etc/my.cnf` (Linux/Mac).
2. Under `[mysqld]`, sett eller endre:
   ```ini
   bind-address = 0.0.0.0
   ```
3. Restart MySQL i XAMPP Control Panel.
4. Gi root-brukeren tilgang fra Docker-nettverket (kjør i phpMyAdmin → SQL):
   ```sql
   CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '';
   GRANT ALL PRIVILEGES ON idatg2204_prosjekt.* TO 'root'@'%';
   FLUSH PRIVILEGES;
   ```
   > Bytt `''` til ditt passord hvis du har satt et.

---

## 2. Konfigurer applikasjonen

Rediger `docker-compose.yml` ved behov:

```yaml
environment:
  DB_HOST: host.docker.internal   # Alltid slik for Docker → vertmaskin
  DB_PORT: 3306
  DB_USER: root
  DB_PASSWORD: ""                 # Endre hvis du har passord
  DB_NAME: idatg2204_prosjekt
```

---

## 3. Bygg og start

```bash
# Klon / kopier prosjektmappen til serveren, deretter:
cd idatg2204-dashboard

docker compose up --build -d
```

Applikasjonen er nå tilgjengelig på:
```
http://<serverens-ip>:5000
```

---

## 4. Stopp / restart

```bash
docker compose down          # Stopp
docker compose up -d         # Start igjen (uten rebuild)
docker compose up --build -d # Start med rebuild
docker compose logs -f web   # Se logger
```

---

## 5. Struktur

```
.
├── app.py              ← Flask-backend med alle SQL-spørringer
├── templates/
│   └── index.html      ← Enkeltside-frontend
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── README.md
```

---

## 6. Funksjonalitet

| Nr | Spørring |
|----|----------|
| 1 | Uløste hendelser eldre enn N dager – gruppert per bygg |
| 2 | Vedlikeholdsarbeidsbelastning per tekniker for en gitt uke |
| 3 | Hendelser som krevde flere vedlikeholdsoppgaver |
| 4 | Gjennomsnittlig løsningstid per hendelseskategori |
| 5 | Ressurser som er overutnyttet i en gitt periode |
| 6 | Hendelser som ble gjenåpnet etter resolved |
| 7 | Teknikere og totale timer jobbet per uke |
| 8 | Alle hendelser rapportert av en spesifikk bruker |
| 9 | Oppgavetildelinger som overlapper i tid for samme tekniker |
| 10 | Hendelser og oppgaver for et spesifikt bygg i en datoperiode |
| ✎ | Egendefinert SQL-spørring (kun SELECT) |

---

## 7. API-endepunkter

| Metode | URL | Beskrivelse |
|--------|-----|-------------|
| GET | `/` | Webgrensesnitt |
| POST | `/api/run/<q1-q10>` | Kjør forhåndsdefinert spørring |
| POST | `/api/custom` | Kjør egendefinert SQL |
| GET | `/api/health` | Sjekk databaseforbindelse |

### Eksempel – kjør spørring 1 med curl:
```bash
curl -X POST http://localhost:5000/api/run/q1 \
  -H "Content-Type: application/json" \
  -d '{"days": 7}'
```
