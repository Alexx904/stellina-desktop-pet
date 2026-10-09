# 3. TASK LIST: BACKLOG INIZIALE & STATO ATTIVITÀ

> Tutti i task iniziali sono impostati su `[ ]` (da fare) e prioritizzati in base all'esito dell'onboarding.

---

## Legenda Stati
- `[ ]` da fare
- `[~]` implementato e verificato internamente con evidenze, in attesa di accettazione del Product Owner
- `[x]` accettato dal Product Owner (spostato in `docs/4_CHANGELOG.md` se superati 10 task)
- `[!]` bloccato (con motivo indicato)

---

## Epic 1: Qualità, Test Suite & Baseline di Caratterizzazione (Priorità Alta)

### Story 1.1: Infrastruttura di Test e Caratterizzazione dei Moduli Core
*Obiettivo: Colmare la totale assenza di test nel repository creando una suite automatizzata eseguibile via SPM e CI.*

- [ ] **E1-S1-T1 · Configurazione Target di Test in Package.swift**
  - File: `Package.swift`, `Tests/StellinaTests/`
  - Dipende da: nessuno
  - Test: `swift test` (happy)
  - DoD: Target `StellinaTests` dichiarato in `Package.swift` con test suite di base eseguibile senza errori.

- [ ] **E1-S1-T2 · Test di Caratterizzazione per PhysicsSystem**
  - File: `Sources/Stellina/Core/PhysicsSystem.swift`, `Tests/StellinaTests/PhysicsSystemTests.swift`
  - Dipende da: `E1-S1-T1`
  - Test: `PhysicsSystemTests.swift` (calcolo gravità, atterraggio a `groundY`, rimbalzo bordi orizzontali `minX`/`maxX`)
  - DoD: Copertura unitaria del 100% sulla logica di calcolo matematico e collisione orizzontale.

- [ ] **E1-S1-T3 · Test di Caratterizzazione per PetNeedsManager**
  - File: `Sources/Stellina/Core/PetNeedsManager.swift`, `Tests/StellinaTests/PetNeedsManagerTests.swift`
  - Dipende da: `E1-S1-T1`
  - Test: `PetNeedsManagerTests.swift` (decadimento temporale, ricarica con `pet()` e `feed()`, trigger soglie critiche < 25%, persistenza e restore con decadimento offline)
  - DoD: Validazione deterministica delle formule di decadimento e delle notifiche di soglia.

- [ ] **E1-S1-T4 · Test di Caratterizzazione per BehaviorSystem e PetState**
  - File: `Sources/Stellina/Core/BehaviorSystem.swift`, `Tests/StellinaTests/BehaviorSystemTests.swift`
  - Dipende da: `E1-S1-T1`, `E1-S1-T2`
  - Test: `BehaviorSystemTests.swift` (transizioni di stato drag/fall/sleep/pet, carrot follower trigger, reset inattività)
  - DoD: Test isolati sul decision engine comportamentale con mock o frame deterministici.

- [ ] **E1-S1-T5 · Integrazione di `swift test` nella CI GitHub Actions**
  - File: `.github/workflows/build.yml`
  - Dipende da: `E1-S1-T1`
  - Test: Workflow GitHub Actions su runner `macos-latest`
  - DoD: Step `swift test` inserito nel workflow prima del packaging con esito verde garantito.

---

## Epic 2: Manutenibilità & Pulizia del Repository (Priorità Media)

### Story 2.1: Bonifica Configurazioni e Script di Packaging
- [ ] **E2-S1-T1 · Pulizia file `.gitignore` e rimozione residui obsoleti**
  - File: `.gitignore`
  - Dipende da: nessuno
  - Test: `git status`, verifica integrità file
  - DoD: Rimozione di righe estranee a Swift/macOS (es. direttive Python / build Windows non utilizzate) per mantenere pulito il repository.

- [ ] **E2-S1-T2 · Robustezza e gestione errori in `scripts/build_app.sh`**
  - File: `scripts/build_app.sh`, `Makefile`
  - Dipende da: nessuno
  - Test: Esecuzione script di build in ambiente macOS
  - DoD: Controllo esplicito su fallimento di `codesign`, validazione presenza di tutti gli asset prima del confezionamento bundle.

---

## Epic 3: Robustezza Funzionale & Perfezionamento Desktop (Priorità Bassa)

### Story 3.1: Supporto Multi-Monitor Dinamico
- [ ] **E3-S1-T1 · Ascolto variazione parametri schermo (`didChangeScreenParametersNotification`)**
  - File: `Sources/Stellina/Core/PhysicsSystem.swift`, `Sources/Stellina/AppDelegate.swift`
  - Dipende da: `E1-S1-T2`
  - Test: Test unitario o simulazione cambio `visibleFrame`
  - DoD: Stellina e le carote si riposizionano automaticamente all'interno dei limiti sicuri visibili se la risoluzione dello schermo cambia o se un monitor secondario viene connesso/disconnesso.
