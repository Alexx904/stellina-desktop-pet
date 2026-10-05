# 🐾 Stellina - Desktop Pet (macOS & Windows)

**Stellina** è un'adorabile applicazione desktop pet cross-platform, fluida a 60 FPS e con un consumo di risorse praticamente nullo (< 0.5% CPU).
Nativa per **macOS** (scritta in Swift con AppKit + SwiftUI) e dotata di build standalone per **Windows** (`Stellina.exe`).

---

## 🌟 Funzionalità

- **Finestra Trasparente & Floating**: Stellina vive sul tuo desktop sopra tutte le altre finestre senza cornici o sfondi opachi, e ti accompagna anche a schermo intero.
- **Fisica & Gravità Elastica (Cartoon Squish & Stretch)**:
  - Cade dall'alto e atterra sul pavimento dello schermo con un rimbalzo morbido (*squish*).
  - Quando la trascini in aria si allunga verso l'alto (*stretch*) come un gattino.
- **💖 Coccole & Pat-Pat Interattivo**:
  - Sfiora velocemente il mouse avanti e indietro sopra Stellina per farle le carezze: fa le fusa e sprigiona una pioggia di **cuoricini ❤️ fluttuanti**!
  - Disponibile anche con clic destro -> *"Fai le Coccole 💖"*.
- **💤 Modalità Sonno Naturale (Sleep Mode)**:
  - Se lasci Stellina indisturbata per qualche minuto, si accoccola ed entra nel mondo dei sogni con le bollicine **`Zzz`** 💤.
  - Passa il cursore su di lei per svegliarla con un allegro saltino di bentornato!
- **🔊 Effetti Sonori Dolci & Rilassanti**:
  - Feedback audio per carezze/fusa, atterraggio, sollevamento e risveglio.
  - Switch Muto e regolazione volume disponibili nel menu rapido e nelle impostazioni.
- **Drag & Drop Diretto**: Puoi prenderla con il mouse e spostarla ovunque; rilasciandola cadrà di nuovo per gravità.
- **Accessory App su macOS (Zero Dock Bloat)**: Vive discreta nella **Barra dei Menu** in alto con l'icona zampetta 🐾.
- **Interfaccia Impostazioni Dedicata (SwiftUI)**:
  - **Sprite & Aspetto**: personalizzazione degli sprite di movimento con selezione file dal Finder e pulsante *Ripristina Default*.
  - **Fisica & Movimento**: regolazione di dimensione (px), velocità di camminata, intensità di gravità e frequenza fotogrammi.
  - **Interazioni & Audio**: toggle effetti sonori, volume, abilitazione carezze e tempo di inattività sonno.
  - **Hot Reload**: ogni modifica ha effetto istantaneo senza dover riavviare l'applicazione!

---

## 📂 Struttura del Progetto

```
stellina-desktop-pet/
├── Assets Stellina/                      # Sprite grafici di default
│   ├── Fall.png
│   ├── Idle.png
│   ├── left1.png
│   ├── left2.png
│   ├── right1.png
│   └── right2.png
├── Package.swift                         # Configurazione Swift Package Manager
├── Makefile                              # Scorciatoie per compilazione macOS & Windows
├── scripts/
│   ├── build_app.sh                     # Script di generazione bundle macOS .app
│   ├── build_windows.bat                # Script batch compilazione Stellina.exe
│   └── build_windows.ps1                # Script PowerShell compilazione Stellina.exe
├── Resources/
│   ├── Info.plist                        # Configurazione bundle macOS
│   └── Stellina.entitlements              # Permessi sandbox
└── Sources/
    ├── Stellina/                         # Codice sorgente nativo macOS (Swift)
    │   ├── main.swift                    # Entry point NSApplication
    │   ├── AppDelegate.swift             # Ciclo di vita applicativo
    │   ├── Core/
    │   │   ├── PetState.swift            # Macchina a stati (idle, walk, fall, dragged, petted, sleeping)
    │   │   ├── PetSettings.swift         # Persistenza preferenze (UserDefaults) e hot reload
    │   │   ├── PhysicsSystem.swift       # Motore gravità e piano terra
    │   │   ├── BehaviorSystem.swift      # Timer decisionale, inattività e suoni
    │   │   ├── SoundManager.swift        # Gestione audio ed effetti sonori nativi
    │   │   └── AssetManager.swift        # Caricamento intelligente da bundle o file custom
    │   └── UI/
    │       ├── PetWindow.swift           # NSPanel borderless trasparente flottante
    │       ├── PetView.swift             # Rendering CALayer, gesture pat-pat e particelle
    │       ├── StatusBarController.swift # Icona zampetta 🐾 nella barra di stato
    │       └── Settings/
    │           ├── SettingsWindowController.swift
    │           ├── SettingsView.swift
    │           ├── SpriteSettingsView.swift
    │           ├── PhysicsSettingsView.swift
    │           └── InteractionsSettingsView.swift
    └── Windows/                          # Codice sorgente per Windows
        └── main.py                       # App Windows con fisica, particelle e suoni
```

---

## 🚀 Compilazione ed Esecuzione

### 🍎 Su macOS

```bash
# Compilazione e avvio rapido in sviluppo
make run

# Generazione applicazione autonoma Stellina.app
make package
# oppure: ./scripts/build_app.sh
```
Il bundle standalone verrà generato in `build/Stellina.app`.

---

### 🪟 Su Windows

Per generare l'eseguibile standalone **`Stellina.exe`** (senza console nera di sfondo):

```powershell
# Esegui lo script di build PowerShell:
powershell -ExecutionPolicy Bypass -File scripts\build_windows.ps1

# Oppure tramite il file batch:
scripts\build_windows.bat
```

L'eseguibile autonomo pronto all'uso verrà creato all'interno di:
```
build\Stellina-Windows\Stellina.exe
```
Basta fare doppio clic su `Stellina.exe` per avviare subito la tua Stellina!
