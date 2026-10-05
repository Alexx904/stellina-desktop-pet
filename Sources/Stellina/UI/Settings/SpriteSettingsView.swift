import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct SpriteSettingsView: View {
    @ObservedObject var settings = PetSettings.shared

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personalizzazione Sprite")
                            .font(.headline)
                        Text("Sostituisci i frame di movimento. Di default vengono usati i file di 'Assets Stellina'.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Ripristina Default") {
                        settings.resetToDefaults()
                    }
                }
                .padding(.bottom, 8)

                Divider()

                // Sezione Idle
                spriteSlotRow(
                    title: "Inattivo (Idle)",
                    subtitle: "Stellina ferma a terra",
                    currentCustomPath: settings.customIdlePath,
                    defaultName: "Idle.png"
                ) { newPath in
                    settings.customIdlePath = newPath
                } onReset: {
                    settings.customIdlePath = nil
                }

                Divider()

                // Sezione Cammina Sinistra
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cammina a Sinistra")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    spriteSlotRow(
                        title: "Frame 1",
                        subtitle: "Passo sinistro 1",
                        currentCustomPath: settings.customWalkLeftPaths.indices.contains(0) ? settings.customWalkLeftPaths[0] : nil,
                        defaultName: "left1.png"
                    ) { newPath in
                        updateWalkLeft(index: 0, path: newPath)
                    } onReset: {
                        resetWalkLeft(index: 0)
                    }

                    spriteSlotRow(
                        title: "Frame 2",
                        subtitle: "Passo sinistro 2",
                        currentCustomPath: settings.customWalkLeftPaths.indices.contains(1) ? settings.customWalkLeftPaths[1] : nil,
                        defaultName: "left2.png"
                    ) { newPath in
                        updateWalkLeft(index: 1, path: newPath)
                    } onReset: {
                        resetWalkLeft(index: 1)
                    }
                }

                Divider()

                // Sezione Cammina Destra
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cammina a Destra")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    spriteSlotRow(
                        title: "Frame 1",
                        subtitle: "Passo destro 1",
                        currentCustomPath: settings.customWalkRightPaths.indices.contains(0) ? settings.customWalkRightPaths[0] : nil,
                        defaultName: "right1.png"
                    ) { newPath in
                        updateWalkRight(index: 0, path: newPath)
                    } onReset: {
                        resetWalkRight(index: 0)
                    }

                    spriteSlotRow(
                        title: "Frame 2",
                        subtitle: "Passo destro 2",
                        currentCustomPath: settings.customWalkRightPaths.indices.contains(1) ? settings.customWalkRightPaths[1] : nil,
                        defaultName: "right2.png"
                    ) { newPath in
                        updateWalkRight(index: 1, path: newPath)
                    } onReset: {
                        resetWalkRight(index: 1)
                    }
                }

                Divider()

                // Sezione Caduta
                spriteSlotRow(
                    title: "In Caduta (Fall)",
                    subtitle: "Quando viene trascinata o cade dall'alto",
                    currentCustomPath: settings.customFallPath,
                    defaultName: "Fall.png"
                ) { newPath in
                    settings.customFallPath = newPath
                } onReset: {
                    settings.customFallPath = nil
                }

                Divider()

                // Sezione Sonno
                spriteSlotRow(
                    title: "Addormentato (Sleep)",
                    subtitle: "Quando Stellina riposa dopo inattività",
                    currentCustomPath: settings.customSleepPath,
                    defaultName: "Sleep.png"
                ) { newPath in
                    settings.customSleepPath = newPath
                } onReset: {
                    settings.customSleepPath = nil
                }
            }
            .padding(20)
        }
    }

    private func updateWalkLeft(index: Int, path: String) {
        var paths = settings.customWalkLeftPaths
        while paths.count <= index {
            paths.append("")
        }
        paths[index] = path
        settings.customWalkLeftPaths = paths
    }

    private func resetWalkLeft(index: Int) {
        var paths = settings.customWalkLeftPaths
        if paths.indices.contains(index) {
            paths.remove(at: index)
        }
        settings.customWalkLeftPaths = paths
    }

    private func updateWalkRight(index: Int, path: String) {
        var paths = settings.customWalkRightPaths
        while paths.count <= index {
            paths.append("")
        }
        paths[index] = path
        settings.customWalkRightPaths = paths
    }

    private func resetWalkRight(index: Int) {
        var paths = settings.customWalkRightPaths
        if paths.indices.contains(index) {
            paths.remove(at: index)
        }
        settings.customWalkRightPaths = paths
    }

    @ViewBuilder
    private func spriteSlotRow(
        title: String,
        subtitle: String,
        currentCustomPath: String?,
        defaultName: String,
        onSelect: @escaping (String) -> Void,
        onReset: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 16) {
            // Anteprima
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )

                if let path = currentCustomPath, let img = NSImage(contentsOfFile: path) {
                    Image(nsImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                } else {
                    // Carica default
                    let defaultImg = loadDefaultImage(named: defaultName)
                    if let dImg = defaultImg {
                        Image(nsImage: dImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(currentCustomPath == nil ? "Default (\(defaultName))" : "Personalizzato")
                    .font(.caption)
                    .foregroundColor(currentCustomPath == nil ? .secondary : .accentColor)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if currentCustomPath != nil {
                Button("Ripristina") {
                    onReset()
                }
                .buttonStyle(.bordered)
            }

            Button("Sfoglia...") {
                chooseImageFile { selectedPath in
                    if let selectedPath = selectedPath {
                        onSelect(selectedPath)
                    }
                }
            }
        }
    }

    private func chooseImageFile(completion: @escaping (String?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .jpeg, .image]
        panel.prompt = "Seleziona Sprite"

        if panel.runModal() == .OK, let url = panel.url {
            completion(url.path)
        } else {
            completion(nil)
        }
    }

    private func loadDefaultImage(named name: String) -> NSImage? {
        if let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "Assets Stellina") {
            return NSImage(contentsOf: url)
        }
        if let resURL = Bundle.main.resourceURL?.appendingPathComponent("Assets Stellina").appendingPathComponent(name) {
            return NSImage(contentsOf: resURL)
        }
        let localPath = "Assets Stellina/\(name)"
        if FileManager.default.fileExists(atPath: localPath) {
            return NSImage(contentsOfFile: localPath)
        }
        return nil
    }
}
