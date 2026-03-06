# CPU Monitoring Dashboard

## Konsept
Dette prosjektet samler CPU-bruk fra klienter (sampler skrevet i C++) og sender målinger til en nettjeneste med database. Brukere kan sammenligne CPU-bruken sin med andre. Målet er å bygge en komplett løsning: klient, API, database, frontend for visualisering og sammenligning, samt dokumentasjon og brukerstøtte. (AI ble brukt til å lage ReadMe, CHANGELOG og TODO.)

> Kort: Klient måler CPU → Backend lagrer → Frontend viser tall og grafer.

---

## Kompetansemål: Brukerstøtte
Prosjektet dekker flere kompetansemål innen brukerstøtte:

- **Etiske retningslinjer og lovverk**  
  - Personvern- og samtykkedokumentasjon (GDPR).
- **Brukerstøtte og veiledning**  
  - Skrive brukerveiledning og FAQ for installasjon og innsending av målinger.
- **Kartlegging og utvikling av veiledninger**  
  - Trinnvise guider for installasjon og rapportering av CPU-data.
- **Opplæring og kursmateriell**  
  - Slides / screencasts som viser hvordan løsningen brukes.
- **Kommunikasjon og terminologi**  
  - Dokumentasjon tilpasset både tekniske og ikke-tekniske brukere.
- **Feilsøking og kvalitetssikring**  
  - Logging, testplan og feilsøkingsdokument. Monitoring, backup og oppetidsovervåking.
- **Håndtering av krevende situasjoner**  
  - Supportprosedyrer og eskaleringsrutiner.
- **Etiske vurderinger**  
  - Hvordan aggregert CPU-data påvirker brukere og samfunnet.
- **Samarbeid og samhandlingsverktøy**  
  - GitHub/Git for versjonskontroll, issues og pull requests.
- **Likeverdig og inkluderende praksis**  
  - Retningslinjer for tilgjengelig og inkluderende brukerstøtte.

---

## Kompetansemål: Utvikling
Prosjektet dekker også utviklingskompetanse:

- **Programmeringsspråk**  
  - Vurdering av språkvalg for klient, backend og frontend.
- **Funksjonelle krav**  
  - API, datalagring og brukergrensesnitt (MVP og videreutvikling).
- **Brukergrensesnitt og tjenestedesign**  
  - Wireframes og brukertesting for dashboardet.
- **Teknisk dokumentasjon**  
  - API-dokumentasjon, databaseskjema og installasjonsveiledning.
- **Versjonskontroll**  
  - Git: commits, branches, pull requests.
- **IT-tjenester med innebygget personvern**  
  - Anonymisering, samtykke og datalagringspolicy.
- **Sikkerhet**  
  - Threat modelling, autentisering, rate-limiting og input-validering.
- **Testing**  
  - Enhetstester, integrasjonstester, end-to-end tester.
- **Database-design**  
  - Tidsseriedata, brukerrelasjoner, queries, indekser og backup.

---

## To-do-liste
**MVP (Minimum viable product)**

- [ ] API for innsending av CPU-data (REST/JSON)  
- [ ] Databaseskjema (bruker, enhet, tidsseriedata)  
- [ ] Klientintegrasjon: sende CPU-målinger til API (autentisert)  
- [ ] Dashboard: historikk og sammenligning  
- [ ] Brukerautentisering (signup/login)  
- [ ] Enhetstesting og integrasjonstesting  
- [ ] Dokumentasjon: installasjon og brukerveiledning  
- [ ] Personvern / samtykke og lovverksjekk  

**Utvidelser og kvalitet**

- [ ] Brukerrolle og delingsinnstillinger  
- [ ] Anonymisering og aggregering for personvern  
- [ ] Rate-limiting, input-validering og logging  
- [ ] Skalerbar datalagring (TimescaleDB/InfluxDB/PostgreSQL)  
- [ ] CI/CD, containerisering og deploy (Docker, GitHub Actions)  
- [ ] Monitoring og alerting for API og DB  
- [ ] Kursmateriale og brukerstøtte-dokumenter  

> Tips: Oppdater `TODO.md` etter hvert som oppgaver fullføres.

---

## Changelog
Se `CHANGELOG.md` for dag-for-dag endringslogg.

---

## Hvordan bidra
- Lag en issue for nye funksjoner eller bugs  
- Opprett en branch per feature  
- Åpne pull request med beskrivelse og hvilke tester som er kjørt  

---

## Begrunnelse for valg
- **Klient i C++**: Lavt ressursforbruk, presise CPU-målinger via plattform-API-er (f.eks. macOS Mach-API).  
- **Modulær struktur (system/, sampler/, ui/)**: Enkelt vedlikehold og testing, tydelig ansvarfordeling.  
- **Sampling-design med delt snapshot**: Mer presise målinger, poll-loop kan styre frekvens uten blokkering.  
- **Personvern og anonymisering**: Minimering av persondata, tidlig fokus på GDPR.  
- **Backend og datamodell**: Tidsseriedata i TimescaleDB/InfluxDB/Postgres for effektiv lagring og spørring.  
- **Testing og drift**: CI/CD, enhetstester og overvåking for kvalitet og oppetid.

---

## Universell utforming og TTS
- Dashboardet bruker **tekstbasert informasjon i tillegg til grafer**.  
- **Tab-navigasjon** og **ARIA-labels** gjør det mulig for blindbrukere å navigere og høre oppdateringer.  
- Oppdatering hvert 5. sekund med siste 30 målinger gir kort og lesbar tidsserie.  
- Tall og grafbeskrivelser er synlige for alle brukere og lesbare for skjermlesere.

---
