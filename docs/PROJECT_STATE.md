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
| ONBOARD-01 | Onboarding architetturale & documentale | Revisione di `docs/` e `PROJECT_STATE.md` | 2026-10-09 |

## Bloccati / Domande aperte per l'utente

- (nessuno)

## Assunzioni fatte (da confermare)

- L'applicazione rimane 100% nativa macOS (Apple Silicon + Intel) e non è previsto porting multi-piattaforma.
- La prima priorità tecnica concordata è l'introduzione di una test suite headless per i moduli Core (`PhysicsSystem`, `PetNeedsManager`, `BehaviorSystem`).

## Decisioni recenti (ultime 10, dettagli negli ADR)

- 2026-10-09: ADR-01 · AppKit + CALayer per il pet flottante non invasivo
- 2026-10-09: ADR-02 · SwiftUI per il pannello preferenze tramite NSHostingController
- 2026-10-09: ADR-03 · Zero dipendenze di terze parti (solo SDK standard Apple)

## Prossimi passi

1. Validazione dell'onboarding e della documentazione da parte del Product Owner.
2. Esecuzione del primo task del backlog: `E1-S1-T1` (Configurazione target di test in `Package.swift`).

## Log sessioni (ultime 5, la più recente in alto)

- 2026-10-09 · Eseguito workflow /onboard completo: mappatura stack, reverse engineering architettura, requisiti dedotti, baseline e backlog prioritizzato · Build CI PASS, suite test da creare.

