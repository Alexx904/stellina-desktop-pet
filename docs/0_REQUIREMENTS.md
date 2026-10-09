# REQUISITI DI PROGETTO: STELLINA DESKTOP PET

> Stato: **Bozza da validare** (Requisiti ricavati tramite reverse engineering del codice sorgente e della documentazione esistente, in data 09/10/2026).

---

## 1. Visione del Prodotto

**Stellina** è un compagno virtuale interattivo (Desktop Pet) per macOS, leggero, privo di dipendenze esterne, con grafica sprite 2D e animazioni procedurali a 60 FPS (simulation loop a ~30 FPS).
L'applicazione è concepita come un accessorio da scrivania (`LSUIElement`) non invasivo, che vive sopra ogni finestra e su tutti gli Spaces, combinando fisica simulata, gamification in stile Tamagotchi e interazioni tattili col cursore del mouse.

---

## 2. Requisiti Funzionali Dedotti

*Tutti i requisiti seguenti sono marcati come `[Dedotto, da validare]` in quanto ricostruiti dall'analisi del codice.*

### RF-01: Finestra Flottante e Trasparente
- **Descrizione:** Il pet viene renderizzato all'interno di una finestra `NSPanel` senza bordi né barra del titolo, con sfondo completamente trasparente.
- **Comportamento:**
  - Livello finestra: `.floating` (sempre visibile sopra le normali finestre applicative).
  - Supporto multi-spazio: visibile su tutti i desktop virtuali (`.canJoinAllSpaces`) e compatibile con app a schermo intero (`.fullScreenAuxiliary`).
  - L'applicazione opera in modalità accessoria senza comparire nel Dock macOS.
- **Riferimento:** `PetWindow.swift`, `Info.plist`, `AppDelegate.swift`.

### RF-02: Simulazione Fisica e Gravità
- **Descrizione:** Movimento verticale e orizzontale guidato da regole fisiche newtoniane semplificate.
- **Comportamento:**
  - Se il pet si trova sopra il "pavimento" (bordo inferiore dell'area visibile dello schermo `NSScreen.main.visibleFrame`), subisce un'accelerazione gravitazionale verso il basso.
  - All'atterraggio si attiva un effetto procedurale di rimbalzo ed elasticità (*squish & bounce*) e viene riprodotto il suono di atterraggio.
  - Movimento orizzontale autonomo: il pet sceglie periodicamente se restare inattivo o camminare a destra/sinistra.
  - Rimbalzo ai margini laterali dello schermo: se tocca i bordi destro o sinistro, inverte la direzione di camminata.
- **Riferimento:** `PhysicsSystem.swift`, `BehaviorSystem.swift`, `PetView.swift`.

### RF-03: Drag & Drop Diretto del Personaggio
- **Descrizione:** L'utente può afferrare Stellina con il tasto sinistro del mouse e trascinarla ovunque sullo schermo.
- **Comportamento:**
  - Durante il click prolungato il pet subisce uno allungamento elastico verticale (*squish & stretch*).
  - Al rilascio (`mouseUp`), il pet ritorna alla forma proporzionata e, se rilasciato a mezz'aria, precipita per gravità fino al suolo.
- **Riferimento:** `PetView.swift`, `BehaviorSystem.swift`.

### RF-04: Coccole e Interazione Tattile (Pat-Pat)
- **Descrizione:** Muovendo rapidamente il cursore a destra e sinistra sopra la testa di Stellina si innescano le coccole.
- **Comportamento:**
  - Visualizzazione di un overlay animato con una manina che accarezza la testa (`headpat-hand.gif`).
  - Deformazione ciclica di flessione e schiacciamento (*squish & bend*) del pet a ritmo di carezza.
  - Emissione di particelle fluttuanti a forma di cuoricino (`❤️`) e riproduzione del suono fusa (`Purr`).
  - Ricarica dell'indicatore di Affetto nella gamification.
- **Riferimento:** `PetView.swift`, `BehaviorSystem.swift`, `SoundManager.swift`.

### RF-05: Inclinazione Curiosa delle Orecchie (Curious Ear Tilt)
- **Descrizione:** Al passaggio del mouse nei pressi di Stellina, la testolina si inclina verso il puntatore.
- **Comportamento:**
  - Rotazione procedurale leggera di `spriteLayer` calcolata in base alla distanza orizzontale dal centro.
  - Ritorno fluido in posizione eretta quando il mouse si allontana.
  - Disattivabile dall'utente nelle preferenze.
- **Riferimento:** `PetView.swift`, `PetSettings.swift`.

### RF-06: Ciclo del Sonno e Risveglio
- **Descrizione:** Gestione del riposo autonomo e manuale del pet.
- **Comportamento:**
  - Dopo un periodo di inattività configurabile (default: 2 minuti), Stellina si accoccola ed entra nello stato `.sleeping` (sprite `Sleep.png`).
  - Durante il sonno vengono emesse periodicamente bolle di testo fluttuanti `Zzz` (`z`, `Zz`, `ZzZz`, `💤`).
  - Passando il mouse sopra Stellina addormentata, si sveglia con un saltello di gioia (`hop`) e un suono (`Tink`).
  - È possibile forzare l'addormentamento o il risveglio dal menu contestuale o dalla barra dei menu.
- **Riferimento:** `BehaviorSystem.swift`, `PetView.swift`, `StatusBarController.swift`.

### RF-07: Inseguimento Carota e Nutrizione
- **Descrizione:** Meccanica interattiva di alimentazione tramite carote virtuali.
- **Comportamento:**
  - Spawn carote: manuale (tasto destro / status bar / settings) o automatico (ogni 3 minuti se ce ne sono meno di 3 a schermo).
  - Massimo 3 carote contemporaneamente a schermo; le carote cadono per gravità sul pavimento.
  - Trascinando una carota con il cursore del mouse, Stellina si sveglia (se dorme) e si dirige a passo svelto verso la posizione orizzontale della carota.
  - Se la carota è mantenuta sopra di lei, Stellina si posiziona sotto di essa ed esegue saltelli di attesa.
  - Se la carota tocca il corpo del coniglietto (o vi cade sopra), viene consumata: animazione di scomparsa con rotazione, particelle di cibo (`🥕`, `🔸`, `✨`, `🧡`), sequenza di morsi sonori (`Pop`, `Purr`, `Pop`) e ricarica della sazietà.
- **Riferimento:** `CarrotManager.swift`, `CarrotView.swift`, `CarrotWindow.swift`, `BehaviorSystem.swift`.

### RF-08: Gamification e Sistema Bisogni (Tamagotchi Engine)
- **Descrizione:** Simulazione del benessere del pet con due indicatori vitali (0–100%):
  - **Affetto / Coccole:** ricaricato dalle carezze e dal menu rapido.
  - **Sazietà / Fame:** ricaricato mangiando le carote.
- **Comportamento:**
  - Decadimento continuo nel tempo calibrato in minuti (configurabile).
  - Decadimento calcolato anche a computer spento / app chiusa (fino a max 20-30% di calo offline).
  - Soglia critica (< 25%):
    - Coccole basse: compare il badge fluttuante `🥺`.
    - Fame bassa: compare il badge `🤤` e si attiva l'animazione di brontolio di pancia (`triggerTummyRumble`).
    - Entrambi bassi: badge combinato `🥺🥕`.
  - La gamification è disattivabile integralmente; in tal caso i badge vengono nascosti e il pet opera in modalità sandbox.
- **Riferimento:** `PetNeedsManager.swift`, `PetView.swift`, `PetSettings.swift`.

### RF-09: Integrazione con la Barra dei Menu di macOS
- **Descrizione:** Icona di stato `🐾` nella barra dei menu di sistema.
- **Comportamento:**
  - Mostra lo stato aggiornato dei bisogni (`💖 Coccole: X% | 🥕 Sazietà: Y%`).
  - Menu a discesa con comandi rapidi: Addormenta / Sveglia, Lancia Carota, Riposiziona al Centro, Impostazioni, Esci.
- **Riferimento:** `StatusBarController.swift`.

### RF-10: Menu Contestuale al Tasto Destro
- **Descrizione:** Cliccando con il tasto destro sul corpo di Stellina si apre un menu con gli stessi controlli della status bar.
- **Riferimento:** `PetView.swift`.

### RF-11: Pannello Impostazioni SwiftUI
- **Descrizione:** Finestra delle preferenze articolata in 5 tab:
  1. *Sprite & Aspetto:* selezione file immagine personalizzati dal Finder per ogni stato (`Idle`, `WalkLeft 1-2`, `WalkRight 1-2`, `Fall`, `Sleep`) con anteprima e pulsanti di ripristino default.
  2. *Fisica & Movimento:* slider per dimensione finestra (80-300px), velocità camminata, gravità, velocità fotogrammi (tick), e preset rapidi (Calmo, Standard, Vivace).
  3. *Interazioni & Audio:* toggle audio generale, slider volume (10-100%), pulsanti di test sonoro, toggle coccole, soglia inattività sonno (1-10 min), pulsante lancia carota/cibo.
  4. *Bisogni & Accessori:* toggle gamification, visualizzazione barre di progresso live, toggle badge emoji critici, regolazione tempi di decadimento, pulsante "Ricarica tutto al 100% ✨", toggle Curious Ear Tilt.
  5. *Informazioni:* versione app, credits, pulsante riposiziona e pulsante chiudi app.
- **Riferimento:** `SettingsView.swift` e relative sotto-viste.

### RF-12: Riconoscimento Ideatore dell'Applicazione
- **Descrizione:** Citazione esplicita di **Alessandro Miniello** come ideatore e autore di Stellina Desktop Pet.
- **Comportamento:**
  - Nel tab "Informazioni" del pannello Impostazioni compare una sezione dedicata ben visibile con nome dell'ideatore ("Ideato da Alessandro Miniello").
  - Nel menu rapido della barra dei menu (`StatusBarController`) e nel menu contestuale col tasto destro è presente una voce o indicazione informativa sull'ideatore.
  - Indicazione riportata nella documentazione e nel `README.md`.
- **Riferimento:** `SettingsView.swift`, `StatusBarController.swift`, `PetView.swift`, `README.md`.

### RF-13: Selezione Personaggi Standard (Coniglio, Cane, Gatto)
- **Descrizione:** L'utente può scegliere quale personaggio standard visualizzare sul desktop tra Coniglio (Stellina 🐰), Cagnolino (🐶) e Gattino (🐱).
- **Comportamento:**
  - Selettore di personaggio accessibile in cima al tab "Sprite & Aspetto" del pannello Impostazioni.
  - Al cambio personaggio, l'applicazione ricarica a runtime i corrispettivi sprite predefiniti (`Assets Stellina/`, `Assets Cane/`, `Assets Gatto/`).
  - La personalizzazione slot-per-slot continua a funzionare sovrascrivendo i singoli frame se l'utente carica immagini proprie.
  - L'impostazione del personaggio viene salvata in `UserDefaults` e ripristinata al riavvio.
- **Riferimento:** `PetCharacter.swift`, `PetSettings.swift`, `AssetManager.swift`, `SpriteSettingsView.swift`.

### RF-14: Selezione Alimenti & Snack per il Pet
- **Descrizione:** L'utente può selezionare quale alimento lanciare e far mangiare al pet, con supporto a molteplici cibi tipici oltre alla carota.
- **Comportamento:**
  - Ampia scelta di alimenti: Carota 🥕, Osso 🦴, Pesce 🐟, Bistecca 🥩, Formaggio 🧀, Mela 🍎, Biscotto 🍪.
  - Selettore di cibo integrato nelle Impostazioni (tab "Interazioni & Audio"), nel menu a discesa della barra dei menu (`StatusBarController`) e nel menu tasto destro.
  - L'elemento a schermo renderizza l'emoji specifica dell'alimento selezionato (`CarrotView`/`FoodView`).
  - Quando il pet consuma il cibo, l'animazione di masticazione emette particelle colorate a tema con l'alimento scelto.
  - La preferenza del cibo viene persistita in `UserDefaults`.
- **Riferimento:** `FoodType.swift`, `CarrotManager.swift`, `CarrotView.swift`, `PetView.swift`, `InteractionsSettingsView.swift`, `StatusBarController.swift`.


---

## 3. Requisiti Non Funzionali

- **RNF-01 Piattaforma:** macOS 12.0 (Monterey) o superiore (Universal Binary arm64 / x86_64).
- **RNF-02 Prestazioni e Consumi:** Utilizzo CPU trascurabile (< 0.5% in stato idle), rendering hardware accelerato via `CALayer` e `QuartzCore`, timer a intervalli controllati (~30 FPS).
- **RNF-03 Dipendenze Esterne:** Nessuna dipendenza di terze parti (zero framework esterni, dipendenza esclusivamente da API native Apple: `AppKit`, `SwiftUI`, `Combine`, `QuartzCore`, `ImageIO`).
- **RNF-04 Privacy e Sicurezza:** Nessun accesso alla rete, nessuna telemetria, salvataggio dei dati esclusivamente in locale tramite `UserDefaults`.
- **RNF-05 Persistenza:** Tutte le modifiche ai parametri fisici, percorsi sprite e stato bisogni sono persistite immediatamente e ricaricate al riavvio.

---

## 4. Non-Goals / Limitazioni Attuali Rilevate

- **NG-01:** Supporto per sistemi operativi non-macOS (Windows, Linux): l'applicazione dipende strettamente da `AppKit`, `NSPanel`, `NSScreen`, `NSSound` e `SwiftUI macOS`.
- **NG-02:** Modalità multiplayer o sincronizzazione cloud tra dispositivi.
- **NG-03:** Gestione dinamica avanzata multi-monitor quando una finestra attraversa contemporaneamente due schermi con scale diverse (attualmente si ancora a `NSScreen.main`).
- **NG-04:** Suite di test automatizzata: attualmente il repository non include test unitari o di integrazione (`Tests/` assente).
