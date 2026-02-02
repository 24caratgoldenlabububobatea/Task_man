# ReadMe

## Konsept 
Dette prosjektet samler CPU-bruk fra klienter (sampler skrevet i C++) og sender målinger til en nettjeneste med database, hvor brukere kan sammenligne CPU-bruken sin med andre. Målet er å bygge en komplett løsning: klient, API, database, frontend for visualisering og sammenligning, samt tilhørende dokumentasjon og brukerstøtte. (AI ble brukt for å lage read me, CHANGELOG og TODO.)

> Kort: Klient (sampler) måler CPU, backend lagrer målinger, frontend viser grafer og sammenligninger.

---

## Kompetansemål: Brukerstøtte 
Prosjektet dekker flere kompetansemål innen brukerstøtte ved å implementere konkrete oppgaver:

- **Gjøre rede for og anvende etiske retningslinjer og relevant lovverk i eget arbeid**
  - Lage personvern- og samtykkedokumentasjon for datainnsamling (GDPR/lover som gjelder).
- **Utøve brukerstøtte og veilede i relevant programvare**
  - Skrive brukerveiledning og FAQ for installasjon og opplasting av målinger.
- **Kartlegge behovet for og utvikle veiledninger for brukere og kunder**
  - Lage trinnvise guider for hvordan klienten installeres og rapporterer data.
- **Utvikle kursmateriell og gjennomføre kurs i relevante IT-systemer**
  - Lage korte opplæringsmoduler (slides / screencasts) som viser hvordan løsningen brukes.
- **Bruke og tilpasse kommunikasjonsform og fagterminologi**
  - Dokumentasjon som er tilpasset tekniske og ikke-tekniske brukere.
- **Feilsøke og rette feil ved hjelp av feilsøkingsstrategier**
  - Implementere logging, testplan og feilsøkingsdokument.
- **Beskrive og bruke rammeverk for kvalitetssikring av IT-drift**
  - Oppsett for monitoring, backup, og oppetidsovervåking.
- **Håndtere krevende situasjoner i kontakt med brukere og kunder**
  - Prosesser for support og eskalering.
- **Reflektere over hvordan intelligente systemer påvirker bransjen og samfunnet**
  - Vurdere hvordan aggregert CPU-data kan brukes og hvilke etiske utfordringer som finnes.
- **Bruke og administrere samhandlingsverktøy som effektiviserer samarbeid**
  - Bruke GitHub/Git for versjonskontroll og issues for oppgaver.
- **Drøfte krav til et likeverdig og inkluderende yrkesfellesskap**
  - Utarbeide retningslinjer for inkluderende brukerstøtte.

---

## Kompetansemål: Utvikling 
Prosjektets utviklingsarbeid dekker følgende kompetansemål:

- **Vurdere fordeler og ulemper ved ulike programmeringsspråk**
  - Beslutte hvilke språk som brukes for klient/backend/frontend, og forklare valgene.
- **Lage og begrunne funksjonelle krav**
  - Dokumentasjon av krav til API, lagring og UI (MVP og videreutvikling).
- **Vurdere brukergrensesnitt og designe tjenester tilpasset brukerne**
  - Lage wireframes og brukertester for dashboardet.
- **Utarbeide teknisk dokumentasjon**
  - Lage API-dokumentasjon, skjemaer og installasjonsveiledning.
- **Beskrive og anvende relevante versjonskontrollsystemer**
  - Bruke Git for commits, branches og pull requests.
- **Designe og implementere IT-tjenester med innebygget personvern**
  - Anonymisering av data, samtykke og lagringspolicy.
- **Analysere trusler og utvikle applikasjoner med innebygget sikkerhet**
  - Threat modelling, autentisering, rate-limiting og input-validering.
- **Anvende relevant testmiljø og utføre testing**
  - Enhetstester, integrasjonstester og end-to-end tester.
- **Modellere og opprette databaser for informasjonsflyt**
  - Database-design for tidsseriedata og brukerrelasjoner.
- **Beskrive datalagringsmodeller og metoder for å hente/sette inn data**
  - Dokumentere queries, indeksstrategier og backup.

---

## To-do-liste 
Prioritert rekkefølge (MVP først):

**MVP (Minimum viable product)**
- [ ] Lage API for innsending av CPU-data (REST/JSON)
- [ ] Designe databaseskjema (bruker, enhet, tidsseriedata)
- [ ] Klientintegrasjon: sende CPU-målinger til API (autentisert)
- [ ] Dashboard: visning av historikk og sammenligning med andre brukere
- [ ] Brukerautentisering (signup/login)
- [ ] Enhetstesting og integrasjonstesting for kritiske deler
- [ ] Dokumentasjon: installasjonsveiledning og brukerveiledning
- [ ] Personvern / samtykke og relevant lovverksjekk

**Utvidelser & kvalitet**
- [ ] Brukerrolle og delingsinnstillinger (hvem kan se data)
- [ ] Anonymisering og aggregering for personvern
- [ ] Rate-limiting, input validering og logging
- [ ] Skalerbar datalagring (timescaleDB / InfluxDB / PostgreSQL)
- [ ] CI/CD, containerisering og deploy (Docker, GitHub Actions)
- [ ] Monitoring og alerting for API og DB
- [ ] Kursmateriale og brukerstøtte-dokumenter

> Tips: Bruk denne lista i `TODO.md` og oppdater etterhvert som oppgaver fullføres.

---

## Changelog 
Se `CHANGELOG.md` for dag-for-dag endringslogg.

---

## Hvordan bidra 
- Lag en issue for nye funksjoner eller bugs
- Opprett en branch per feature
- Åpne pull request med beskrivelse og hvilke tester som er kjørt

---

## Hvorfor disse valgene / Begrunnelse 
Her forklarer vi kort hvorfor jeg har gjort de viktigste valg i prosjektet og hvordan disse valgene støtter læringsmålene og prosjektets mål:

- **Klient i C++**: Valgt for lavt ressursforbruk og tilgang til plattformspesifikke API-er (f.eks. macOS Mach-API) som gir presise CPU-målinger. Dette viser vurdering av programmeringsspråk og tekniske fordeler/ulemper.
- **Modulær struktur (system/, sampler/, ui/)**: Gir enkel vedlikehold, enkel testing og tydelig ansvarfordeling (single responsibility). Letter versjonskontroll og samarbeid.
- **Sampling-design med delt snapshot (stateful monitor)**: Bruker tidligere snapshot for å beregne delta, i stedet for å blokkere med sleep i selve målingen. Gir mer presise målinger og lar poll-loopen sette ønsket frekvens.
- **Personvern og anonymisering**: Tidlig fokus på samtykke, anonymisering og minimalt lagret persondata for å oppfylle GDPR-krav og etiske retningslinjer.
- **Backend og datamodell**: Tidssseriedata i en egnet DB (f.eks. TimescaleDB/InfluxDB/Postgres) for effektiv lagring og spørring. API design (REST/JSON) for enkel integrasjon.
- **Testing og drift**: CI/CD, enhetstester og overvåking planlegges for å sikre kvalitet og driftssikkerhet.

### Hvordan prosjektet møter kompetansemålene
- **Brukerstøtte**: Dokumentasjon, brukerveiledninger og supportprosedyrer støtter opplæringsmål for veiledning, feilsøking og kvalitetssikring.
- **Utvikling**: Tekniske valg (språk, DB, API), design av personvern, testing og dokumentasjon dekker de tekniske kompetansemålene knyttet til utvikling og sikkerhet.
- **Tverrfaglig læring**: Prosjektet kombinerer teknisk implementasjon med etiske vurderinger og brukerstøtte, noe som gir praktisk arbeid med både tekniske og yrkesfaglige mål.

---

**Kontakt / ansvarlig**
- Legg inn kontaktinfo eller ansvarlig gruppe her.

---

_Trenger du at jeg lager `TODO.md` og `CHANGELOG.md` også? Svar så genererer jeg dem._
