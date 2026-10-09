# 1. CONTESTO DI PROGETTO: STELLINA DESKTOP PET

> Stato: **Bozza da validare** (Generato in fase di onboarding automatico il 09/10/2026).

---

## 1. Sintesi del Progetto

**Stellina Desktop Pet** è un compagno virtuale leggero, reattivo e divertente per macOS. L'applicazione risiede sullo schermo dell'utente come una creatura viva che reagisce agli input del mouse, cade per gravità, gioca con carote virtuali, dorme se lasciata a riposo e manifesta affetto quando accarezzata.

Il progetto è sviluppato interamente in linguaggio **Swift 5.9+**, mirando a **macOS 12.0 (Monterey)** e versioni successive, sfruttando la combinazione di **AppKit** (per finestre trasparenti non vincolate al Dock e gestione eventi di basso livello), **QuartzCore / CALayer** (per animazioni fluide e a basso consumo) e **SwiftUI / Combine** (per il pannello impostazioni e la gestione reattiva dello stato).

---

## 2. Obiettivi Chiave

1. **Massima Leggerezza:** Consumo energetico e computazionale quasi nullo (< 0.5% CPU su MacBook con Apple Silicon / Intel).
2. **Nessun Impatto Visivo Invasivo:** Finestra borderless trasparente senza sfondo opaco, assenza di icona nel Dock (`LSUIElement = true`), presenza discreta nella barra di stato (`🐾`).
3. **Interattività e Gamification Intuitiva:** Meccaniche fisiche tangibili (trascinamento, caduta, rimbalzo) abbinate a bisogni naturali (coccole e sazietà) con reazioni visive chiare (badge emoji, brontolio pancia, briciole, particelle cuori).
4. **Zero Dipendenze di Terze Parti:** Nessun package SPM esterno o libreria C; affidabilità garantita dal solo SDK standard Apple.

---

## 3. Requisiti Non Funzionali di Riferimento

| Requisito | Specifica |
|---|---|
| **Sistema Operativo Target** | macOS 12.0+ (Universal Binary: Apple Silicon `arm64` + Intel `x86_64`) |
| **Toolchain di Compilazione** | Swift 5.9+, Xcode 14.0+, Swift Package Manager |
| **Persistenza** | `UserDefaults` (impostazioni e livello bisogni) |
| **Frame Rate & Tick** | Simulation loop a ~30 Hz (0.033s), rendering display link a 60 FPS |
| **Connettività / Privacy** | 100% offline, nessuna telemetria o richiesta di rete |

---

## 4. Indice Documentale

| File | Scopo |
|---|---|
| [`AGENTS.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/AGENTS.md) | Regole operative di governance per l'agente TechLead / QA |
| [`docs/PROJECT_STATE.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/PROJECT_STATE.md) | Memoria viva: Project Profile, baseline verifiche, task attivi, log sessioni |
| [`docs/0_REQUIREMENTS.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/0_REQUIREMENTS.md) | Requisiti funzionali e use case dettagliati |
| [`docs/1_PROJECT_CONTEXT.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/1_PROJECT_CONTEXT.md) | Questo documento (visione, obiettivi, contesto) |
| [`docs/2_ARCHITECTURE.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/2_ARCHITECTURE.md) | Architettura moduli, diagrammi di flusso, modello dati, convenzioni |
| [`docs/3_TASK_LIST.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/3_TASK_LIST.md) | Piano di lavoro: Epic, Story e Task prioritizzati con stato di verifica |
| [`docs/4_CHANGELOG.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/4_CHANGELOG.md) | Storico delle feature completate e accettate dal Product Owner |
| [`docs/_legacy/MAPPING.md`](file:///c:/Users/aless/Desktop/Sviluppo/GitHub/stellina-desktop-pet/docs/_legacy/MAPPING.md) | Mappatura delle fonti preesistenti e conflitti risolti |
