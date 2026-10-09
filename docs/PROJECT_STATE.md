# PROJECT STATE

> Memoria viva dell'agente. Letta a inizio sessione, aggiornata a fine di ogni turno.
> Non cancellare sezioni: se vuote, scrivi "nessuno".

**Ultimo aggiornamento:** 2026-10-09  
**Modalità progetto:** esistente (onboarded il 2026-10-09)  
**Fase:** Manutenzione & Qualità  

## Project Profile

```
Nome progetto:           Stellina Desktop Pet
Linguaggi/stack:         Swift 5.9+ / AppKit + SwiftUI + QuartzCore / macOS 12.0+ (Monterey)
Gestore pacchetti:       Swift Package Manager (SPM)
Comando test mirati:     swift test --filter <TargetTest> (target in fase di definizione - E1-S1-T1)
Comando suite completa:  swift test (target in fase di definizione - E1-S1-T1)
Comando build/typecheck: swift build (oppure: make build, ./scripts/build_app.sh)
Comando lint/format:     nessun linter configurato (proposto SwiftLint)
Percorsi per livello:    core=Sources/Stellina/Core ui=Sources/Stellina/UI settings=Sources/Stellina/UI/Settings assets="Assets Stellina" packaging=scripts/build_app.sh
Prerequisiti ambiente:   macOS 12.0+ con Xcode 14+ / Swift 5.9+. Nota: l'ambiente di lavoro corrente è Windows; i comandi di build/test macOS sono eseguiti tramite GitHub Actions o richiedono una macchina macOS.
Come avviare l'app:      open build/Stellina.app (oppure: make run su macOS)
Branch principale:       main
Comandi vietati:         rm -rf fuori repo, git push --force, alterazione file di sistema
```

## Baseline test (prima di ogni intervento)

| Data | Comando | Esito | Fallimenti preesistenti noti |
|---|---|---|---|
| 2026-10-09 | `swift test` | Non configurato | Assenza totale di test target e test suite nel repository (censito in E1-S1-T1). |
| 2026-10-09 | `./scripts/build_app.sh` (CI) | PASS (in GitHub Actions) | Build release e confezionamento Universal Binary funzionanti su runner `macos-latest`. Non eseguibile localmente su host Windows. |

## In corso

- (nessuno)

## In attesa di accettazione utente

| Task | Feature | Come provarla (sintesi) | Consegnata il |
|---|---|---|---|
| E4-S1-T1 | Riconoscimento Ideatore Alessandro Miniello | Apri tab Informazioni in Impostazioni, o apri menu bar / context menu tasto destro | 2026-10-09 |
| E4-S1-T2 | Personaggi Standard Multipli (Cane e Gatto) | Impostazioni -> Sprite & Aspetto -> Seleziona Cagnolino 🐶 o Gattino 🐱 | 2026-10-09 |
| E4-S1-T3 | Cibi & Snack Selezionabili Multipli | Impostazioni -> Interazioni, oppure menu contestuale/status bar -> Scegli Snack | 2026-10-09 |

## Bloccati / Domande aperte per l'utente

- (nessuno)

## Assunzioni fatte (da confermare)

- Ciascun personaggio possiede uno snack naturale preferito di default (Coniglio->Carota, Cane->Osso, Gatto->Pesce), ma l'utente può scegliere liberamente qualsiasi alimento.
- I set di sprite generati per Cane e Gatto (`Assets Cane/`, `Assets Gatto/`) includono le pose `Idle`, `Fall`, `Sleep`, `left1-2`, `right1-2` con trasparenza alpha nativa.

## Decisioni recenti (ultime 10, dettagli negli ADR)

- 2026-10-09: Supporto multi-personaggio standard via `PetCharacter` e cartelle asset isolate
- 2026-10-09: Catalogo cibi esteso via `FoodType` con emoji dinamiche e particelle dedicate
- 2026-10-09: Box dedicato all'ideatore Alessandro Miniello in UI e metadati di progetto
- 2026-10-09: ADR-01 · AppKit + CALayer per il pet flottante non invasivo
- 2026-10-09: ADR-02 · SwiftUI per il pannello preferenze tramite NSHostingController
- 2026-10-09: ADR-03 · Zero dipendenze di terze parti (solo SDK standard Apple)

## Prossimi passi

1. Monitorare l'esito della build automatica su GitHub Actions per il branch `feat/multi-pet-food-credits`.
2. Accettazione da parte del Product Owner dei task di Epic 4 (`E4-S1-T1`, `E4-S1-T2`, `E4-S1-T3`).
3. Sviluppo di Epic 1 (target di test SPM e test di caratterizzazione).

## Log sessioni (ultime 5, la più recente in alto)

- 2026-10-10 · Aggiornato `.github/workflows/build.yml` per supportare il trigger su `feat/**` e pushato il branch `feat/multi-pet-food-credits` su GitHub (`origin`) su richiesta esplicita dell'utente per avviare il build su GitHub Actions.
- 2026-10-09 · Perfezionati sprite di camminata per Cane e Gatto: generati sprite in profilo laterale con passo e zampe differenziate (left: zampe sinistre avanti, right: zampe destre avanti) · Asset aggiornati e verificati.
- 2026-10-09 · Implementata Epic 4: Alessandro Miniello come ideatore, personaggi standard Cane e Gatto con sprite nativi, catalogo cibi (Carota, Osso, Pesce, Bistecca, Formaggio, Mela, Biscotto) e particelle VFX a tema · Moduli pronti per accettazione.
- 2026-10-09 · Eseguito workflow /onboard completo: mappatura stack, reverse engineering architettura, requisiti dedotti, baseline e backlog prioritizzato · Build CI PASS, suite test da creare.




