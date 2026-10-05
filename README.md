# 🐾 Stellina — macOS Desktop Pet

<p align="center">
  <img src="Assets Stellina/Idle.png" alt="Stellina Desktop Pet" width="160" />
</p>

<p align="center">
  <strong>Un compagno virtuale nativo per macOS leggero, interattivo e animato a 60 FPS.</strong><br>
  Sviluppato in <em>Swift</em>, <em>AppKit</em> e <em>SwiftUI</em>, con simulazione fisica in tempo reale, gamification, inseguimento carote, interazioni tattili e consumo di risorse CPU quasi nullo (< 0.5%).
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

---

### 🥕 Inseguimento Carota in Mano (Carrot Follower AI) & Nutrizione
- **Inseguimento Dinamico**: Quando afferri una carota con il cursore del mouse, Stellina si sveglia (se stava dormendo), si gira verso la carota e **la insegue a passo svelto** camminando sul desktop!
- **Saltelli Gioiosi di Attesa**: Se tieni la carota ferma sopra di lei, si posiziona esattamente sotto il cibo ed esegue piccoli saltelli di anticipazione (`hop`).
- **Drag & Drop e Masticazione**:
  - Trascina la carota verso il coniglietto o lasciala cadere vicino a lui per fargliela sgranocchiare.
  - **Animazione Cartoon di Masticazione**: Movimenti rapidi di sgranocchiamento (*munching bounce*).
  - **Effetti Particellari (VFX)**: Briciole arancioni, cuoricini e stelline (`🥕`, `🔸`, `✨`, `🧡`).
  - **Effetti Sonori (SFX)**: Sequenza ritmica e croccante di morsi (*crunch*).

---

### 💖 Gamification & Sistema Bisogni (Tamagotchi Engine)
- **Barre di Benessere in Tempo Reale**:
  - 💖 **Coccole / Affetto** (`0–100%`): ricaricabile accarezzandola col mouse o tramite menu rapido.
  - 🥕 **Sazietà / Nutrizione** (`0–100%`): ricaricabile dandole da mangiare le carote.
- **Decadimento Naturale nel Tempo**: le statistiche scendono gradualmente a ritmo configurabile dalle impostazioni.
- **Badge Emoji e Reazioni Procedurali (< 25%)**:
  - **Coccole Basse (< 25%)**: appare un badge fluttuante con emoji **🥺** (oppure **🥺🥕** se mancano entrambi) che rimbalza dolcemente sopra la testolina.
  - **Fame Bassa (< 25%)**: appare il badge **🤤** e il pancino di Stellina borbotta visibilmente con un simpatico scuotimento orizzontale (`tummyRumble`).
- **Completamente Disattivabile**: Puoi disattivare la gamification in qualsiasi momento dalle impostazioni; i badge spariranno all'istante e Stellina tornerà in modalità sandbox.

---

### 🎀 Accessori Equipaggiabili sulla Testa
- Personalizza il look di Stellina con graziosi accessori ancorati alla testolina:
  - **Nessuno**
  - **Fiocchetto Rosa 🎀**
  - **Fiorellino 🌸**
  - **Cappellino da Festa 🥳**
  - **Corona Reale 👑**
  - **Stellina Dorata ⭐**
- Gli accessori ereditano in tempo reale tutte le trasformazioni del pet (allungamento elastico, schiacciamento, salti e camminata).
- Selezionabili comodamente dal tab *Bisogni & Accessori* delle Impostazioni, dal menu contestuale del pet o dall'icona nella StatusBar.

---

### 🐰 Curious Ear Tilt (Inclinazione Curiosa delle Orecchie)
- Quando muovi il cursore del mouse nelle vicinanze di Stellina, la testolina e le orecchie si inclinano dolcemente verso la direzione del puntatore, guardandolo incuriosite, per poi ritornare elastiche al centro.

---

### ✨ Effetto Lucciole Notturne (Orario Serale PC)
- **Rilevamento Orario di Sistema**: Dalle **19:30 alle 07:00** del mattino (in base all'orologio del tuo Mac), graziose lucciole luminescenti (✨, 🟡, 🌟) fluttuano morbidamente con traiettorie sinusoidali attorno a Stellina, creando un'atmosfera magica e rilassante mentre riposa o passeggia.

---

### 💖 Coccole & Affetto (Pat-Pat)
- **Carezze Naturali con il Mouse**: Muovendo rapidamente il cursore a destra e sinistra sopra la testa di Stellina:
  - Appare una mano animata in sovrimpressione (`headpat-hand.gif`).
  - Stellina reagisce con una deformazione ritmica sincrona di schiacciamento e flessione (*squish & bend*).
  - Emette fusa e un tripudio di **cuoricini fluttuanti ❤️** che evaporano dolcemente.
- Ricarica istantaneamente l'indicatore di Affetto della gamification!

---

### 💤 Sonno Naturale & Messa a Riposo Manuale
- **Addormentamento Naturale**: Se non interagisci con Stellina per un tempo configurabile (default: 2 minuti), si accoccola ed entra in sonno profondo, emettendo periodicamente bolle **`Zzz`** 💤.
- **Controllo Diretto del Sonno**: Metti a dormire o sveglia Stellina a comando dal menu del tasto destro (*"Metti a Dormire 💤"* / *"Sveglia Stellina ☀️"*).
- **Risveglio Dolce**: Sfiora il mouse su di lei per vederla balzare in piedi con un saltino felice.

---

### 🐾 Zero Invasività (Accessory App)
- Nessuna icona ingombrante nel Dock: Stellina risiede in modo pulito nella **Barra dei Menu** di macOS con l'icona zampetta (`🐾`).
- Indicatore live dello stato dei bisogni: `💖 Coccole: 85% | 🥕 Sazietà: 60%`.
- Sottomenu rapido con spunta grafica per cambiare accessori al volo.

---

### ⚙️ Pannello Impostazioni Moderno (SwiftUI)
- **Sprite & Aspetto**: Carica sprite personalizzati dal Finder per ogni stato (`Idle`, `Walk`, `Fall`, `Sleep`).
- **Fisica & Movimento**: Regola dimensioni finestra (px), velocità di camminata, gravità e velocità animazione.
- **Interazioni & Audio**: Volume suoni, toggle audio fusa/cibo, soglia di inattività per il sonno e pulsante lancia carota.
- **Bisogni & Accessori**:
  - Barre di progresso per Coccole e Fame.
  - Velocità di decadimento configurabili in minuti.
  - Selettore accessori con preview.
  - Toggle per *Curious Ear Tilt* e *Lucciole Notturne Serali*.
- **Hot-Reload Istantaneo**: Ogni impostazione si aggiorna in tempo reale senza riavvii.

---

## 🎮 Controlli Rapidi

| Gesto / Azione | Effetto |
| :--- | :--- |
| **Trascina Pet (Click Sinistro)** | Sposta Stellina sulla scrivania (allungamento elastico); al rilascio cade. |
| **Trascina una Carota con il mouse** | Stellina si sveglia e **insegue la carota** a passo svelto; fermandosi sotto di essa fa salti d'attesa (`hop`). |
| **Trascina Carota verso Stellina** | Stellina mangia la carota, ricarica la sazietà, fa briciole e suoni crunch. |
| **Passa il mouse avanti/indietro sulla testa** | Fai le coccole a Stellina (mano animata, fusa, cuoricini, ricarica affetto). |
| **Muovi il mouse vicino a Stellina** | Inclinazione curiosa della testolina (*Curious Ear Tilt*). |
| **Tasto Destro su Stellina** | Mostra stato bisogni, menu coccole, sonno, carota, sottomenu accessori e impostazioni. |
| **Icona Zampetta (Barra Menu) 🐾** | Visualizza percentuali `💖 / 🥕`, selettore accessori rapido, controllo sonno e impostazioni. |
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
        │   ├── BehaviorSystem.swift      # Decision engine comportamentale, carrot follow, coccole e sonno
        │   ├── PhysicsSystem.swift       # Fisica newtoniana, gravità e collisioni coi bordi
        │   ├── CarrotManager.swift       # Gestore carote, coordinate carota in mano e alimentazione
        │   ├── PetNeedsManager.swift     # Engine di gamification (coccole, fame, decadimento e soglie)
        │   ├── SoundManager.swift        # Riproduzione ed effetti sonori nativi (NSSound)
        │   ├── AssetManager.swift        # Caching intelligente sprite e decodifica GIF
        │   └── PetSettings.swift         # Persistenza reattiva UserDefaults con Combine ed enum accessori
        └── UI/
            ├── PetWindow.swift           # NSPanel borderless trasparente a livello floating
            ├── PetView.swift             # Rendering CALayer, badge bisogni, accessori, tilt, lucciole e VFX
            ├── CarrotWindow.swift        # NSPanel autonomo trasparente per ogni carota
            ├── CarrotView.swift          # Vista carota con drag & drop nativo e landing squish
            ├── StatusBarController.swift # Menu item nella barra di stato con livelli bisogni e accessori (🐾)
            └── Settings/                 # Interfaccia preferenze SwiftUI
                ├── SettingsWindowController.swift
                ├── SettingsView.swift
                ├── SpriteSettingsView.swift
                ├── PhysicsSettingsView.swift
                ├── InteractionsSettingsView.swift
                └── GamificationSettingsView.swift # Tab SwiftUI per bisogni, accessori e feature cute
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
