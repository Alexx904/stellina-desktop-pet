# 🐾 Stellina — macOS Desktop Pet

<p align="center">
  <img src="Assets Stellina/Idle.png" alt="Stellina Desktop Pet" width="160" />
</p>

<p align="center">
  <strong>Un compagno virtuale nativo per macOS leggero, interattivo e animato a 60 FPS.</strong><br>
  Sviluppato in <em>Swift</em>, <em>AppKit</em> e <em>SwiftUI</em>, con simulazione fisica in tempo reale, interazioni tattili e consumo di risorse CPU quasi nullo (< 0.5%).
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2012.0+-black?logo=apple&style=flat-square" alt="macOS 12+" />
  <img src="https://img.shields.io/badge/Swift-5.9+-orange?logo=swift&style=flat-square" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/Architecture-Universal%20(Apple%20Silicon%20%2F%20Intel)-blue?style=flat-square" alt="Universal Binary" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
</p>

---

## 🌟 Caratteristiche Principali

### 🐰 Fisica Desktop & Deformazioni Procedurali
- **Finestra Flottante e Trasparente**: Stellina vive sul desktop al di sopra di qualsiasi finestra, senza sfondi opachi né bordi visibili, supportando nativamente gli Spaces e le app a schermo intero (`NSPanel` flottante).
- **Simulazione Gravitazionale**: Cade dolcemente con accelerazione continua, rimbalzando all'impatto con la base dello schermo (*squish & bounce* dinamico).
- **Deformazione Elastica (Squish & Stretch)**: Quando viene afferrata e trascinata col mouse, si allunga verticalmente assecondando il movimento; rilasciandola, riacquista la forma originale e precipita per gravità.

### 🥕 Sistema Interattivo Carota & Nutrizione
- **Carota Flottante con Fisica Reale**: Le carote (`🥕`) compaiono sullo schermo con la stessa identica fisica del coniglietto (caduta gravitazionale, rimbalzo a terra e confini desktop).
- **Drag & Drop Diretto**: Puoi afferrare le carote e trascinarle ovunque sulla scrivania.
- **Meccanica di Nutrizione**:
  - Trascina una carota verso Stellina per fargliela mangiare!
  - **Animazione Cartoon di Masticazione**: Stellina esegue rapidi movimenti di sgranocchiamento cartoon (*munching bounce*).
  - **Effetti Particellari (VFX)**: Pioggia di briciole arancioni, cuoricini e stelline (`🥕`, `🔸`, `✨`, `🧡`).
  - **Effetti Sonori (SFX)**: Sequenza ritmica e croccante di morsi (*crunch*). Se Stellina stava dormendo, si sveglia istantaneamente contenta.
- **Generazione Rapida**: Lancia una carota in qualsiasi momento con il tasto destro (`Lancia Carota 🥕`) o lascia che appaia periodicamente.

### 💖 Coccole & Affetto (Pat-Pat)
- **Carezze Naturali con il Mouse**: Muovendo rapidamente il cursore a destra e sinistra sopra la testa di Stellina:
  - Appare una mano animata in sovrimpressione (`headpat-hand.gif`).
  - Stellina reagisce con una deformazione ritmica sincrona di schiacciamento e flessione (*squish & bend*).
  - Emette fusa e un tripudio di **cuoricini fluttuanti ❤️** che evaporano dolcemente.
- **Attivazione Rapida**: Disponibile anche tramite clic destro -> *"Fai le Coccole 💖"*.

### 💤 Sonno Naturale & Messa a Riposo Manuale
- **Addormentamento Naturale**: Se non interagisci con Stellina per un tempo configurabile (default: 2 minuti), si accoccola ed entra in sonno profondo, emettendo periodicamente bolle **`Zzz`** 💤.
- **Controllo Diretto del Sonno**: Metti a dormire o sveglia Stellina a comando dal menu del tasto destro (*"Metti a Dormire 💤"* / *"Sveglia Stellina ☀️"*).
- **Risveglio Dolce**: Sfiora il mouse su di lei per vederla balzare in piedi con un saltino felice.

### 🐾 Zero Invasività (Accessory App)
- Nessuna icona ingombrante nel Dock: Stellina risiede in modo pulito nella **Barra dei Menu** di macOS con l'icona zampetta (`🐾`).
- Menu contestuale accessibile sia con clic destro sul pet sia dall'icona nella barra di stato.

### ⚙️ Pannello Impostazioni Moderno (SwiftUI)
- **Sprite & Personalizzazione**: Carica asset personalizzati dal Finder per ogni stato (`Idle`, `Walk`, `Fall`, `Sleep`) con supporto al ripristino istantaneo.
- **Fisica & Dinamica**: Regola dimensioni della finestra (px), velocità di camminata, forza di gravità e velocità di animazione.
- **Audio & Interazioni**: Controllo del volume, abilitazione/disabilitazione suoni, test audio per fusa e sgranocchiamento carota, soglia di inattività per il sonno e pulsante rapido per lanciare carote.
- **Hot-Reload Istantaneo**: Ogni impostazione si aggiorna a caldo senza dover riavviare l'applicazione.

---

## 🎮 Controlli Rapidi

| Gesto / Azione | Effetto |
| :--- | :--- |
| **Trascina Pet (Click Sinistro)** | Sposta Stellina sulla scrivania (allungamento elastico); al rilascio cade. |
| **Passa il mouse avanti/indietro** | Fai le coccole a Stellina (mano animata, fusa, cuoricini). |
| **Trascina Carota verso Stellina** | Stellina mangia la carota con animazione di masticazione, briciole e suono crunch. |
| **Tasto Destro su Stellina** | Apre il menu contestuale: coccole, sonno/risveglio, lancia carota, impostazioni, riposiziona. |
| **Icona Zampetta (Barra Menu) 🐾** | Accesso rapido alle impostazioni, controllo sonno, carote e chiusura app. |
| **Passa il mouse sul pet addormentato** | Sveglia Stellina con un saltino. |

---

## 📂 Architettura del Progetto

Il progetto segue un'architettura modulare e pulita senza dipendenze esterne:

```
stellina-desktop-pet/
├── Assets Stellina/                      # Asset grafici di default e animazioni GIF
│   ├── Fall.png                          # Sprite caduta / trascinamento
│   ├── Idle.png                          # Sprite di riposo a terra
│   ├── left1.png / left2.png             # Fotogrammi camminata verso sinistra
│   ├── right1.png / right2.png           # Fotogrammi camminata verso destra
│   ├── Sleep.png                         # Sprite sonno
│   └── headpat-hand.gif                  # Overlay animato per le carezze
├── Package.swift                         # Configurazione Swift Package Manager (macOS 12+)
├── Makefile                              # Target per compilazione, esecuzione e packaging
├── scripts/
│   └── build_app.sh                      # Generazione del bundle autonomo .app (Universal Binary)
├── Resources/
│   ├── Info.plist                        # Configurazione bundle (LSUIElement / Accessory)
│   └── Stellina.entitlements             # Diritti sandbox e hardened runtime
└── Sources/
    └── Stellina/                         # Sorgenti Swift
        ├── main.swift                    # Entry point NSApplication
        ├── AppDelegate.swift             # Orchestrazione ciclo di vita e simulation loop (~30 FPS)
        ├── Core/
        │   ├── PetState.swift            # Macchina a stati finiti (idle, walk, fall, sleep, ecc.)
        │   ├── BehaviorSystem.swift      # Decision engine comportamentale, coccole e sonno
        │   ├── PhysicsSystem.swift       # Fisica newtoniana, gravità e collisioni coi bordi
        │   ├── CarrotManager.swift       # Gestore ciclo vitale, collisioni e feeding carote
        │   ├── SoundManager.swift        # Riproduzione ed effetti sonori nativi (NSSound)
        │   ├── AssetManager.swift        # Caching intelligente sprite e decodifica fotogrammi GIF
        │   └── PetSettings.swift         # Persistenza reattiva UserDefaults con Combine
        └── UI/
            ├── PetWindow.swift           # NSPanel borderless trasparente a livello floating
            ├── PetView.swift             # Rendering CALayer, deformazioni squish/bend, menu e VFX
            ├── CarrotWindow.swift        # NSPanel autonomo trasparente per ogni carota
            ├── CarrotView.swift          # Vista carota con drag & drop nativo e landing squish
            ├── StatusBarController.swift # Menu item nella barra di stato di sistema (🐾)
            └── Settings/                 # Interfaccia preferenze SwiftUI
                ├── SettingsWindowController.swift
                ├── SettingsView.swift
                ├── SpriteSettingsView.swift
                ├── PhysicsSettingsView.swift
                └── InteractionsSettingsView.swift
```

---

## 🛠️ Compilazione ed Esecuzione

### Requisiti
- **macOS 12.0 (Monterey)** o versione successiva
- **Xcode 14.0+** con **Swift 5.9+** (oppure Command Line Tools per Xcode)

### Comandi Rapidi (Makefile)

```bash
# Compila ed esegue direttamente per lo sviluppo locale:
make run

# Compila la release:
make build

# Confeziona il pacchetto finale Stellina.app:
make package

# Pulisce la directory di build:
make clean
```

### Creazione del Bundle Standalone (`.app`)

Lo script [`scripts/build_app.sh`](scripts/build_app.sh) compila un **Universal Binary** nativo per entrambe le architetture Apple Silicon (`arm64`) e Intel (`x86_64`), assembla la cartella `Contents`, include le risorse e applica la firma ad-hoc:

```bash
bash scripts/build_app.sh
```

Il file risultante si troverà in `build/Stellina.app`. Per avviarlo immediatamente:
```bash
open build/Stellina.app
```

---

## 🔒 Prestazioni & Riservatezza

- **Zero Bloat**: Nessun framework o libreria di terze parti; utilizza esclusivamente le API native Apple (`AppKit`, `SwiftUI`, `QuartzCore`, `Combine`).
- **Efficienza Energetica**: La simulazione gira con un timer ad intervalli calibrati (~30 FPS) e accelerazione grafica via `CALayer`, garantendo un impatto termico ed energetico trascurabile su MacBook.
- **Privacy al 100%**: Nessuna connessione di rete, telemetria o raccolta dati. Tutto viene eseguito e memorizzato esclusivamente in locale tramite `UserDefaults`.

---

## 📄 Licenza

Questo progetto è rilasciato sotto licenza [MIT](LICENSE).
Sviluppato con passione per rendere la scrivania del tuo Mac un posto più vivace e accogliente! 💖
