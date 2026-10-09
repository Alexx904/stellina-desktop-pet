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

# 1. Compila la release con Swift Package Manager (Universal Binary arm64 + x86_64)
echo "🔨 Compilazione eseguibile macOS (Universal arm64 + x86_64)..."
BUILD_FLAGS=("-c" "release")
if swift build -c release --arch arm64 --arch x86_64 >/dev/null 2>&1; then
    echo "✅ Compilazione Universal Binary riuscita."
    BUILD_FLAGS+=("--arch" "arm64" "--arch" "x86_64")
else
    echo "ℹ️ SDK multi-architettura non disponibile, compilazione per architettura host..."
    swift build -c release
fi

# 2. Crea la struttura standard del bundle macOS .app
echo "📦 Confezionamento del bundle ${APP_NAME}.app..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 3. Copia l'eseguibile compilato
BIN_PATH="$(swift build "${BUILD_FLAGS[@]}" --show-bin-path)/${APP_NAME}"
if [ ! -f "${BIN_PATH}" ]; then
    echo "❌ Errore: Eseguibile non trovato in ${BIN_PATH}"
    exit 1
fi
cp "${BIN_PATH}" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Verifica architettura binaria prodotta
if command -v lipo >/dev/null 2>&1; then
    echo "ℹ️ Architetture incluse: $(lipo -archs "${MACOS_DIR}/${APP_NAME}")"
fi

# 4. Copia Info.plist
cp "${PROJECT_DIR}/Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"

# 5. Copia gli asset di default (tutti i personaggi standard)
for dir in "Assets Stellina" "Assets Cane" "Assets Gatto"; do
    if [ -d "${PROJECT_DIR}/${dir}" ]; then
        mkdir -p "${RESOURCES_DIR}/${dir}"
        cp -R "${PROJECT_DIR}/${dir}/"* "${RESOURCES_DIR}/${dir}/"
    fi
done


# 6. Firma ad-hoc locale per compatibilità con macOS Gatekeeper / Apple Silicon
echo "🔏 Firma del bundle ad-hoc..."
codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null || true

echo "🎉 Build completata con successo!"
echo "👉 Bundle: ${APP_BUNDLE}"
echo "👉 Per eseguire: open \"${APP_BUNDLE}\""
