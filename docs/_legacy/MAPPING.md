# MAPPING DOCUMENTI ESISTENTI & INTEGRAZIONE

> Data analisi: 09/10/2026

Al momento dell'onboarding, non erano presenti file di documentazione obsoleti o frammentati da archiviare fisicamente in `docs/_legacy/`. L'unica documentazione preesistente era costituita dal file `README.md` principale nella root del repository.

## Tabella di Confluenza

| File Origine | Contenuto Estratto | Destinazione Nuova | Note / Conflitti Risolti |
|---|---|---|---|
| `README.md` | Caratteristiche fisiche, carrot follower, coccole, gamification, menu bar | `docs/0_REQUIREMENTS.md` | Dettagliate le specifiche funzionali dedotte |
| `README.md` | Struttura cartelle e stack tecnologico (Swift 5.9, AppKit, SwiftUI) | `docs/1_PROJECT_CONTEXT.md` e `docs/2_ARCHITECTURE.md` | Standardizzati pattern e responsabilità dei moduli |
| `README.md` | Comandi `make`, requisiti di sistema macOS 12+, Universal Binary | `docs/PROJECT_STATE.md` | Inserito nel Project Profile e comandi di verifica |
| `Package.swift` | Manifest SPM, assenza di test target | `docs/3_TASK_LIST.md` | Creata Epic 1 per introdurre la test suite mancante |
| `scripts/build_app.sh` | Pipeline di packaging `.app`, firma ad-hoc | `docs/2_ARCHITECTURE.md` | Censito come parte del toolchain di packaging |
