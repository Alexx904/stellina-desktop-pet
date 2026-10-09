# 2. ARCHITETTURA DI SISTEMA: STELLINA DESKTOP PET

> Stato: **Bozza da validare** (Reverse engineering del codice completato il 09/10/2026).

---

## 1. Mappa dei Layer e Moduli

Il software è organizzato secondo una struttura modulare disaccoppiata a due livelli principali: **Core Engine** e **UI / Presentation Layer**, coordinati da `AppDelegate`.

```
Sources/Stellina/
├── main.swift                     [Entry Point]
├── AppDelegate.swift              [Life Cycle & Orchestrator]
├── Core/                          [Core Business & Simulation Layer]
│   ├── PetState.swift             (Macchina a stati finiti)
│   ├── BehaviorSystem.swift       (Decision engine comportamentale & timer tick)
│   ├── PhysicsSystem.swift        (Fisica newtoniana, gravità, limiti schermo)
│   ├── CarrotManager.swift        (Gestore spawn, posizionamento e consumo carote)
│   ├── PetNeedsManager.swift      (Gamification engine: affetto, sazietà, decadimento)
│   ├── SoundManager.swift         (Sintesi audio ed effetti sonori di sistema)
│   ├── AssetManager.swift         (Caching sprite e decodifica GIF animate)
│   └── PetSettings.swift          (Modello persistente UserDefaults + Combine)
└── UI/                            [Presentation & Windowing Layer]
    ├── PetWindow.swift            (NSPanel borderless trasparente livello .floating)
    ├── PetView.swift              (CALayer rendering, animazioni procedurali, gestures)
    ├── CarrotWindow.swift         (NSPanel trasparente dedicato a ciascuna carota)
    ├── CarrotView.swift           (Rendering carota, drag & drop ed animazioni consumazione)
    ├── StatusBarController.swift  (NSStatusItem menu bar 🐾 e monitor bisogni)
    └── Settings/                  (Finestra preferenze in SwiftUI)
        ├── SettingsWindowController.swift
        ├── SettingsView.swift
        ├── SpriteSettingsView.swift
        ├── PhysicsSettingsView.swift
        ├── InteractionsSettingsView.swift
        └── GamificationSettingsView.swift
```

---

## 2. Dettaglio dei Moduli e Verifica

### 2.1 Entry Point e Life Cycle
- ✅ **Verificato nel codice** ([`main.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/main.swift#L1-L7)): Istanzia `NSApplication.shared`, imposta `AppDelegate` come delegato ed avvia il loop principale `app.run()`.
- ✅ **Verificato nel codice** ([`AppDelegate.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/AppDelegate.swift#L14-L108)):
  - Imposta la policy `.accessory` (nasconde l'icona nel Dock).
  - Inizializza `StatusBarController` (`🐾`).
  - Inizializza `PetWindow` e `PetView` collegandoli ai callback del motore fisico/comportamentale (`onFrameUpdate`, `onLanded`, `onPetPatTriggered`, `onSleepZzzTriggered`, `onEatTriggered`).
  - Avvia il timer di simulazione a `0.033s` (~30 FPS) eseguito su `RunLoop.main` in modalità `.common`.
  - In `applicationWillTerminate` invalida il timer e rimuove le carote attive a schermo.

### 2.2 Core Layer
- ✅ **Verificato nel codice** ([`PetState.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/PetState.swift#L3-L23)): Enum che definisce gli stati del pet: `.idle`, `.walkLeft`, `.walkRight`, `.falling`, `.dragged`, `.petted`, `.sleeping`.
- ✅ **Verificato nel codice** ([`BehaviorSystem.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/BehaviorSystem.swift#L4-L279)):
  - Singleton `shared`.
  - Ad ogni `tick()`:
    1. Se trascinato (`isDragging`), lo stato è `.dragged`.
    2. Se sopra il suolo (`posY > groundY`), applica la gravità tramite `PhysicsSystem.applyGravity`.
    3. Se al suolo, gestisce la priorità: stato coccolato (`.petted`), inseguimento carota afferrata (`CarrotManager.heldCarrotCenter`), sonno (`.sleeping` con emissione `Zzz`), oppure inattività / camminata autonoma a terra.
    4. Fa avanzare i fotogrammi animati degli sprite in base a `animSpeedTicks`.
    5. Notifica la posizione calcolata e il fotogramma tramite `onFrameUpdate`.
- ✅ **Verificato nel codice** ([`PhysicsSystem.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/PhysicsSystem.swift#L4-L75)):
  - Calcola l'area sicura visibile dello schermo `NSScreen.main?.visibleFrame` (escludendo Dock e Barra Menu).
  - Modella la gravità come accelerazione verso il basso: `velocityY -= currentGravity; posY += velocityY`.
  - Gestisce il rimbalzo e l'inversione di marcia orizzontale quando `posX` eccede `minX` o `maxX(windowWidth:)`.
- ✅ **Verificato nel codice** ([`CarrotManager.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/CarrotManager.swift#L4-L193)):
  - Gestisce una lista di fino a 3 istanze `CarrotItem`.
  - Spawna automaticamente una carota ogni 3 minuti (se il conteggio è < 3) o su richiesta utente.
  - Se una carota è trascinata dall'utente, espone `heldCarrotCenter` a `BehaviorSystem`.
  - Se la distanza tra una carota e il centro del pet è < 75px o i rettangoli si intersecano, scatena la nutrizione (`feedPet`).
- ✅ **Verificato nel codice** ([`PetNeedsManager.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/PetNeedsManager.swift#L4-L134)):
  - Modello `ObservableObject` con valori `@Published` per `affection` e `fullness` (0-100%).
  - Calcola il decadimento lineare ad ogni tick in base a `affectionDecayMinutes` e `hungerDecayMinutes`.
  - Determina le soglie critiche (< 25%) segnalando `isAffectionLow` e `isFullnessLow`.
  - Persiste i valori e il timestamp in `UserDefaults`; all'avvio applica un decadimento retroattivo per il tempo di chiusura (max 20-30%).
- ✅ **Verificato nel codice** ([`SoundManager.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/SoundManager.swift#L4-L70)):
  - Utilizza suoni nativi di sistema di macOS via `NSSound(named:)` (`Pop`, `Purr`, `Bottle`, `Tink`, `Hero`) con fallback su `NSSound.beep()`.
  - Per il consumo carota (`SoundEffect.eat`) riproduce una sequenza ritmica di 3 morsi ravvicinati (`Pop`, `Purr`, `Pop`).
- ✅ **Verificato nel codice** ([`AssetManager.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/AssetManager.swift#L5-L154)):
  - Risolve i file grafici dal bundle dell'app o dalla directory locale in sviluppo (`Assets Stellina/`).
  - Decodifica i frame CGImage e il delay time delle GIF tramite `ImageIO` (`CGImageSourceCreateWithURL`).
  - Fornisce fallback a sprite standard se un percorso personalizzato non è valido.
- ✅ **Verificato nel codice** ([`PetSettings.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/Core/PetSettings.swift#L4-L230)):
  - `ObservableObject` con proprietà reattive `@Published` salvate e ripristinate da `UserDefaults`.
  - Fornisce il metodo `resetToDefaults()` per ripristinare tutti i parametri di fabbrica.

### 2.3 UI & Presentation Layer
- ✅ **Verificato nel codice** ([`PetWindow.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/UI/PetWindow.swift#L3-L28)):
  - Sottoclasse di `NSPanel` con `styleMask: [.borderless, .nonactivatingPanel]`, `backgroundColor = .clear`, `hasShadow = false`, `level = .floating`.
  - `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]`.
  - `canBecomeKey = false`, `canBecomeMain = false` (non ruba mai il focus della tastiera alle altre app).
- ✅ **Verificato nel codice** ([`PetView.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/UI/PetView.swift#L4-L660)):
  - Architettura a layer multipli:
    - `spriteLayer` (Z=10): `contentsGravity = .resizeAspect`, `anchorPoint = (0.5, 0.0)` alla base per deformazioni naturali.
    - `headpatLayer` (Z=50): sovrimpressione animata per `headpat-hand.gif`.
    - `needBadgeLayer` (Z=85): `CATextLayer` con font emoji e animazione fluttuante per bisogni insoddisfatti.
  - Gestione gesture mouse:
    - `mouseMoved`: rileva strokes alternati destra-sinistra ravvicinati per innescare le coccole (pat-pat) e calcola l'angolo di inclinazione di *Curious Ear Tilt*.
    - `mouseDown` / `mouseDragged` / `mouseUp`: trascina la finestra con allungamento elastico verticale.
    - Animazioni Core Animation: `triggerSquishBounce`, `triggerHop`, particelle di cuori, bolle `Zzz`, masticazione e brontolio pancia.
- ✅ **Verificato nel codice** ([`CarrotWindow.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/UI/CarrotWindow.swift) & [`CarrotView.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/UI/CarrotView.swift)):
  - Finestra autonoma borderless per ciascuna carota con emoji `🥕` ad alta risoluzione in `CATextLayer`.
  - Gestione del drag & drop nativo col mouse e animazione di atterraggio (*squish*).
- ✅ **Verificato nel codice** ([`StatusBarController.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/UI/StatusBarController.swift)):
  - Elemento menu bar `🐾` con menu contestuale per controllo del pet e monitor bisogni.
- ✅ **Verificato nel codice** ([`SettingsView.swift`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/Sources/Stellina/UI/Settings/SettingsView.swift)):
  - Interfaccia SwiftUI modulare ospitata in un `NSHostingController` all'interno di `SettingsWindowController`.

---

## 3. Flusso dei Dati e Ciclo di Simulazione

```mermaid
sequenceDiagram
    autonumber
    participant Loop as Simulation Timer (~30 FPS)
    participant Beh as BehaviorSystem
    participant Phys as PhysicsSystem
    participant CMan as CarrotManager
    participant Needs as PetNeedsManager
    participant View as PetView (CALayer)
    participant Win as PetWindow (NSPanel)

    Loop->>Beh: tick()
    alt Pet in Caduta
        Beh->>Phys: applyGravity(posY, velocityY)
        Phys-->>Beh: posY aggiornata
    else Pet al Suolo & Carota in Mano
        Beh->>CMan: heldCarrotCenter?
        CMan-->>Beh: coordinate target
        Beh->>Beh: muove verso carota / hop
    else Pet al Suolo & Inattività
        Beh->>Beh: movimento random / sonno
    end
    Beh->>View: onFrameUpdate(currentImage, position)
    Beh->>Win: setFrameOrigin(point)

    Loop->>CMan: tick(petFrame)
    alt Carota tocca Pet
        CMan->>Beh: feed()
        CMan->>Needs: feed()
        CMan->>View: animateEaten()
    end

    Loop->>Needs: tick(deltaTime = 0.033)
    alt Valori cambiati o soglia < 25%
        Needs->>View: onNeedsStatusAlert / updateNeedBadges()
    end
```

---

## 4. Modello Dati e Persistenza (UserDefaults)

Tutte le impostazioni e lo stato dei bisogni sono memorizzati su chiave-valore nel file preferenze dell'applicazione (`UserDefaults.standard`):

```
+-----------------------------------------------------------------------------------------+
|                                    UserDefaults Key-Value                                |
+-----------------------------------------------------------------------------------------+
| Parametri Fisici & Rendering                                                            |
|  - stellina_window_size               : Double (default 150.0)                          |
|  - stellina_walk_speed                : Double (default 4.0)                            |
|  - stellina_gravity                   : Double (default 2.0)                            |
|  - stellina_anim_speed_ticks          : Int    (default 5)                              |
+-----------------------------------------------------------------------------------------+
| Audio & Interazioni                                                                     |
|  - stellina_sound_enabled             : Bool   (default true)                           |
|  - stellina_sound_volume              : Double (default 0.8)                            |
|  - stellina_petpat_enabled            : Bool   (default true)                           |
|  - stellina_sleep_enabled             : Bool   (default true)                           |
|  - stellina_sleep_idle_seconds        : Double (default 120.0)                          |
+-----------------------------------------------------------------------------------------+
| Gamification & Bisogni                                                                  |
|  - stellina_gamification_enabled      : Bool   (default true)                           |
|  - stellina_show_need_badges          : Bool   (default true)                           |
|  - stellina_affection_decay_minutes   : Double (default 12.0)                           |
|  - stellina_hunger_decay_minutes      : Double (default 10.0)                           |
|  - stellina_curious_ear_tilt_enabled  : Bool   (default true)                           |
|  - stellina_affection_level           : Double (0.0 .. 100.0)                           |
|  - stellina_fullness_level            : Double (0.0 .. 100.0)                           |
|  - stellina_needs_last_save_time      : Date                                            |
+-----------------------------------------------------------------------------------------+
| Custom Sprites (Percorsi file assoluti o nil)                                           |
|  - stellina_custom_idle               : String?                                         |
|  - stellina_custom_walk_left          : [String]                                        |
|  - stellina_custom_walk_right         : [String]                                        |
|  - stellina_custom_fall               : String?                                         |
|  - stellina_custom_sleep              : String?                                         |
+-----------------------------------------------------------------------------------------+
```

---

## 5. Architectural Decision Records (ADR)

### ADR-01: Framework Nativo AppKit + CALayer per il Pet Flottante
- **Contesto:** Serve una finestra desktop non invasiva, priva di decorazioni di sistema, visibile sopra ogni applicazione (inclusi gli Spaces e app full screen) e a consumo CPU quasi nullo.
- **Decisione:** Utilizzo di `NSPanel` borderless con `NSApp.setActivationPolicy(.accessory)` e rendering accelerato via `CALayer` (QuartzCore).
- **Alternative Scartate:**
  - *SwiftUI puro per la finestra pet:* Limiti nell'impostazione fine del livello finestra (`NSWindow.Level.floating`), delle collection behaviors degli Spaces e nell'intercettazione degli eventi mouse a basso livello.
  - *Electron / Webview:* Consumo RAM (> 100MB) e CPU inadatti a un'app di background permanente.
- **Stato:** ✅ Adottato e consolidato nel codice.

### ADR-02: SwiftUI per il Pannello Preferenze
- **Contesto:** Il pannello impostazioni richiede un'interfaccia ricca di controlli (slider, tab, toggle, selettori file con anteprima).
- **Decisione:** Sviluppo in SwiftUI integrato in AppKit tramite `NSHostingController` e collegato a `PetSettings` via `ObservableObject` / `@Published`.
- **Alternative Scartate:** Interfaccia AppKit classica basata su XIB/Storyboard (maggiore verbosità e complessità di layout).
- **Stato:** ✅ Adottato e consolidato nel codice.

### ADR-03: Zero Dipendenze di Terze Parti
- **Contesto:** L'applicazione deve essere facilmente compilabile, distribuibile come Universal Binary e manutenibile senza dipendere da SPM packages esterni.
- **Decisione:** Uso esclusivo del toolchain standard Apple (`Foundation`, `AppKit`, `SwiftUI`, `Combine`, `QuartzCore`, `ImageIO`).
- **Stato:** ✅ Adottato e consolidato nel codice.
