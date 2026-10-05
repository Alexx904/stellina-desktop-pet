# 🐾 Stellina - Desktop Pet per macOS

**Stellina** è un'applicazione desktop pet nativa per macOS, scritta in **Swift (AppKit + SwiftUI)**, leggera, fluida a 60 FPS e con un consumo di CPU praticamente nullo (< 0.5%).

---

## 🌟 Funzionalità

- **Finestra Trasparente & Floating**: Stellina vive sul tuo desktop sopra tutte le altre finestre senza cornici o sfondi opachi, e ti accompagna anche cambiando Spaces o a schermo intero.
- **Fisica & Gravità Reale**: Cade dall'alto, atterra con precisione sulla barra Dock (o in fondo allo schermo), cammina a destra e a sinistra ed effettua rimbalzi sui bordi.
- **Drag & Drop Diretto**: Puoi prenderla con il mouse e spostarla ovunque; rilasciandola cadrà di nuovo per gravità.
- **Accessory App (Zero Dock Bloat)**: Non occupa spazio nel Dock (`LSUIElement = true`), ma vive discreta nella **Barra dei Menu** in alto con l'icona zampetta 🐾.
- **Menu Contestuale & Barra di Sistema**: Clic destro su Stellina o clic sulla zampetta 🐾 per accedere rapidamente alle impostazioni, riposizionarla o uscire.
- **Interfaccia Impostazioni Dedicata (SwiftUI)**:
  - **Sprite & Aspetto**: personalizzazione degli sprite di movimento (Inattivo, Cammina Sinistra, Cammina Destra, Caduta) con selezione file dal Finder e pulsante *Ripristina Default* (basato sulla cartella `Assets Stellina`).
  - **Fisica & Movimento**: regolazione reattiva di dimensione (px), velocità di camminata, intensità di gravità e frequenza fotogrammi.
  - **Hot Reload**: ogni modifica grafica o di fisica ha effetto istantaneo senza dover riavviare l'applicazione!

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
├── Makefile                              # Scorciatoie per compilazione rapida
├── scripts/
│   └── build_app.sh                     # Script di generazione bundle macOS .app
├── Resources/
│   ├── Info.plist                        # Configurazione bundle e LSUIElement
│   └── Stellina.entitlements              # Permessi sandbox
└── Sources/
    └── Stellina/
        ├── main.swift                    # Entry point NSApplication
        ├── AppDelegate.swift             # Ciclo di vita applicativo
        ├── Core/
        │   ├── PetState.swift            # Stati macchina (idle, walkLeft, walkRight, falling, dragged)
        │   ├── PetSettings.swift         # Persistenza preferenze (UserDefaults) e hot reload
        │   ├── PhysicsSystem.swift       # Motore gravità e calcolo piano terra sopra la Dock
        │   ├── BehaviorSystem.swift      # Timer decisionale e intelligenza di movimento
        │   └── AssetManager.swift        # Caricamento intelligente da bundle o file custom
        └── UI/
            ├── PetWindow.swift           # NSPanel borderless trasparente flottante
            ├── PetView.swift             # CALayer sprite renderer e drag & drop nativo
            ├── StatusBarController.swift     # Icona zampetta 🐾 nella barra di stato
            └── Settings/
                ├── SettingsWindowController.swift # Finestra singola per preferenze
                ├── SettingsView.swift             # Vista SwiftUI a schede
                ├── SpriteSettingsView.swift       # Selettore e anteprima sprite
                └── PhysicsSettingsView.swift      # Slider velocità e parametri fisici
```

---

## 🚀 Requisiti e Compilazione su macOS

Non occorre installare Docker, Python o dipendenze esterne. Serve unicamente un Mac con macOS 12.0+ e gli strumenti di sviluppo riga di comando gratuiti di Apple:

```bash
# Se non già installati:
xcode-select --install
```

### 1. Test Rapido in Fase di Sviluppo
Dalla cartella del progetto:
```bash
swift run
```
oppure:
```bash
make run
```

### 2. Generazione del Bundle `.app` Eseguibile Standalone
Per compilare la versione Release e creare l'eseguibile completo **`Stellina.app`**:
```bash
chmod +x scripts/build_app.sh
./scripts/build_app.sh
```
oppure semplicemente:
```bash
make package
```

L'applicazione autonoma verrà creata all'interno della cartella:
```
build/Stellina.app
```

Puoi provarla subito con:
```bash
open build/Stellina.app
```
oppure trascinarla nella tua cartella **Applicazioni** (`/Applications`) per averla sempre disponibile nel Launchpad e aprirla al login.
