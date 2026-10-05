#!/bin/bash
set -e

# Percorsi di lavoro
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Stellina"
BUILD_DIR="${PROJECT_DIR}/build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🌟 =========================================="
echo "🌟 Compilazione di ${APP_NAME} Desktop Pet..."
echo "🌟 =========================================="

cd "${PROJECT_DIR}"

# 1. Compila la release con Swift Package Manager
swift build -c release

# 2. Crea la struttura standard del bundle macOS .app
echo "📦 Confezionamento del bundle ${APP_NAME}.app..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 3. Copia l'eseguibile compilato
BIN_PATH="$(swift build -c release --show-bin-path)/${APP_NAME}"
if [ ! -f "${BIN_PATH}" ]; then
    echo "❌ Errore: Eseguibile non trovato in ${BIN_PATH}"
    exit 1
fi
cp "${BIN_PATH}" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

# 4. Copia Info.plist
cp "${PROJECT_DIR}/Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"

# 5. Copia gli asset di default
mkdir -p "${RESOURCES_DIR}/Assets Stellina"
cp -R "${PROJECT_DIR}/Assets Stellina/"* "${RESOURCES_DIR}/Assets Stellina/"

# 6. Firma ad-hoc locale per compatibilità con macOS Gatekeeper / Apple Silicon
echo "🔏 Firma del bundle ad-hoc..."
codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null || true

echo "🎉 Build completata con successo!"
echo "👉 Bundle: ${APP_BUNDLE}"
echo "👉 Per eseguire: open \"${APP_BUNDLE}\""
