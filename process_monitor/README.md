# CPU Monitoring Dashboard

## Konsept
Dette prosjektet måler CPU-bruk på macOS med en lokal C++‑sampler og tilbyr to klientmodi:
- `monitor`: skriver CPU-prosent til terminalen.
- `monitor_net`: sender CPU-data direkte til en MySQL-database.

Det finnes også en macOS GUI-app (`CPUApp`) som viser CPU-graf, snakker brukeren til og spiller bakgrunnsmusikk.
Backend i `server/app.py` kan vise en enkel dashboard-side og tilbyr en REST-endepunkt for CPU-data.

> Kort: Lokal sampler → MySQL-database / GUI-app → enkel dashboard-backend.

---

## Hva som er implementert
- CPU-sampling på macOS via `system/cpu_process_info.cpp`.
- Enkel terminalklient: `sampler/main.cpp`.
- Nettverksmodus: `sampler/main_net.cpp` som kobler direkte mot MySQL via `system/network.cpp`.
- MySQL-basert lagring av `users` og `cpu_metrics`.
- Flask-backend i `server/app.py` med `/cpu` og `/dashboard`.
- macOS GUI-app i `ui/Frontend.mm` med CPU-graf, tale og musikk.

---

## Kompilering
Kjør fra prosjektroten:

```bash
make monitor
make monitor_net
make CPUApp
```

Forklaring:
- `make monitor` bygger konsoll-sampler.
- `make monitor_net` bygger nettverksklienten som skriver til MySQL.
- `make CPUApp` bygger macOS GUI-appen.

### Avhengigheter
- macOS med `clang++` og Xcode-kommandolinjeverktøy.
- Homebrew `mysql-client` for `monitor_net` og `CPUApp`.
- Python 3 for Flask-backend.
- `pip install flask mysql-connector-python` for `server/app.py`.

---

## Kjøring
### Backend
1. Sørg for at MySQL er tilgjengelig og at databasen er opprettet.
2. Oppdater eventuelt `server/app.py` og `system/network.cpp` med egne MySQL-innstillinger.
3. Start Flask-serveren:

```bash
cd server
python3 app.py
```

Serveren kjører på `http://0.0.0.0:8080`.

### Terminal-sampler
Kjør enten:

```bash
./monitor
```

eller:

```bash
./monitor_net
```

- `./monitor` viser bare CPU-bruken i terminalen.
- `./monitor_net` skriver CPU-målinger direkte til MySQL.

### macOS GUI-app
Kjør:

```bash
./CPUApp
```

Appen viser CPU-graf, gir taleveiledning og spiller valgbar bakgrunnsmusikk.

---

## Arkitektur
- `system/cpu_process_info.cpp` gir `CPUUsageMonitor` for målinger.
- `sampler/main.cpp` er en ren sampler.
- `sampler/main_net.cpp` bruker `system/network.cpp` for databaseoppdatering.
- `ui/Frontend.mm` lager en enkel Cocoa-app på macOS.
- `server/app.py` tilbyr backend og dashboard-logikk.

---

## Kompetansemål: Brukerstøtte
Prosjektet dekker flere kompetansemål innen brukerstøtte:
- **Etiske retningslinjer og lovverk**
  - Bevissthet om personvern i hvordan CPU-data og klient-id lagres.
- **Brukerstøtte og veiledning**
  - README gir konkrete bygge- og kjøreinstruksjoner.
- **Kartlegging og utvikling av veiledninger**
  - Installering og start av backend, klient og GUI er dokumentert.
- **Kommunikasjon og terminologi**
  - Tekst og kommentarer er skrevet for både utviklere og brukere.
- **Feilsøking og kvalitetssikring**
  - Koden har grunnleggende feilmeldinger og README beskriver kjøretrinn.
- **Etiske vurderinger**
  - Prosjektet viser vurdering av dataflyt og lagring av CPU-målinger.
- **Samarbeid og samhandlingsverktøy**
  - Git-vennlig struktur og prosjektorganisering.
- **Likeverdig og inkluderende praksis**
  - GUI-en inkluderer tale og visuell presentasjon av CPU-verdier.

---

## Kompetansemål: Driftstøtte
Prosjektet kan brukes til å oppfylle driftsstøttekompetanser ved å vise hvordan et enkelt målesystem bygges, driftes og dokumenteres:
- **Utforske og beskrive komponenter i en driftsarkitektur**
  - Systemet har klient, databaseforbindelse og backend, og beskriver hvordan de henger sammen.
- **Planlegge, implementere og drifte fysiske og virtuelle løsninger med segmenterte nettverk**
  - `monitor_net` bruker nettverksforbindelse mot MySQL, og backend kan kjøres på separat server.
- **Gjøre rede for prinsipper og strukturer for skytjenester og virtuelle tjenester**
  - Arkitekturen kan overføres til skybaserte tjenester eller virtuelle maskiner.
- **Administrere brukere, tilganger og rettigheter i relevante systemer**
  - MySQL-tilgang og klient-id viser hvordan brukertilgang og dataflyt håndteres.
- **Utforske og beskrive relevante nettverksprotokoller, nettverkstjenester og serverroller**
  - Prosjektet bruker HTTP/Flask og MySQL-klientprotokoll som driftstjenester.
- **Planlegge og dokumentere arbeidsprosesser og IT-løsninger**
  - README dokumenterer bygging, kjøring og konfigurasjon av løsningen.
- **Utforske trusler mot datasikkerhet og gjøre rede for dagens trusselbilde og hvordan truslene kan påvirke en åpen samfunnsdebatt og tilliten til demokratiet**
  - Løsningen viser behovet for sikre tilkoblinger og personvern ved håndtering av data.
- **Gjennomføre risikoanalyse av nettverk og tjenester i en virksomhets systemer og foreslå tiltak for å redusere risikoen**
  - Prosjektet kan reflektere over svakheter som ukryptert trafikk og hardkodede databaselegitimasjoner.

---

## Risikoanalyse

### Identifiserte Sårbarheter

#### 1. **KRITISK: Hardkodede Databaselegitimasjoner**
- **Sted**: `system/network.cpp` linje 10-13 og `server/app.py` linje 7-12
- **Problem**: MySQL-brukernavn, passord og vertsnavn er hardkodet direkte i kildekoden:
  - Bruker: `Jonathan`
  - Passord: `amongusishot34`
  - Vert: `172.20.128.29`
- **Risiko**: Høy
  - Alle som har tilgang til kildekoden får tilgang til databasen
  - Passord eksponeres i Git-historikken for alltid
  - Kan brukes til uautorisert dataagang og manipulasjon
- **Tiltak**:
  - Bruk miljøvariabler: `export DB_PASS=$(cat ~/.db_password)` i koden
  - Bruk `.env`-filer (ikke committ til Git)
  - Bruk hemmelighetsadministrasjonssystemer (AWS Secrets Manager, HashiCorp Vault)
  - Endrе passordet umiddelbar
  - Roter alle hemmeligheter
---

## Kompetansemål: Utvikling
Prosjektet dekker utviklingskompetanse:
- **Programmeringsspråk**
  - C++ for lokal sampling og macOS UI, Python for backend.
- **Funksjonelle krav**
  - Samling av CPU-data, valgfrie lokal- og nettverksklienter, og enkel dashboard-backend.
- **Brukergrensesnitt og tjenestedesign**
  - En enkel terminalklient og en macOS-app med graf og tale.
- **Teknisk dokumentasjon**
  - README dekker bygging, kjøring og avhengigheter.
- **Versjonskontroll**
  - Kildekodestruktur er laget med Git-tankegang i bakhodet.
- **IT-tjenester med innebygget personvern**
  - Lagring av CPU-data i MySQL skjer med et klart klient-id.
- **Database-design**
  - `users` og `cpu_metrics` modeller i server/backend-koden.

---

## To-do-liste
Denne README-en reflekterer hva som er implementert i repoet. Fremtidige forbedringer kan være:
- Lage en fungerende `/dashboard`-frontend i `server/templates/dashboard.html`.
- Bedre API-klient for HTTP-basert innsending til `/cpu`.
- Autentisering og sikrere datatilgang.
- Enhetstester og integrasjonstesting.

Se også `TODO.md` for mer detaljer.

---

## Changelog
Se `CHANGELOG.md` for utviklingshistorikk.

---

## Hvordan bidra
- Lag en issue for feil eller nye funksjoner.
- Opprett en branch per ny funksjon.
- Send pull request med beskrivelse og testinstruksjoner.

---

## Merknader
- `system/network.cpp` bruker direkte MySQL-tilkobling og en klient-id basert på vertsnavn.
- `server/app.py` er konfigurert for `172.20.128.29`; oppdater denne verdi hvis du kjører eget MySQL-oppsett.
- `server/templates/dashboard.html` er foreløpig en plassholder i repoet.
