import AppKit
import Foundation

public final class AssetManager {
    public static let shared = AssetManager()

    private var cache: [PetState: [NSImage]] = [:]
    private let settings = PetSettings.shared

    private init() {
        reloadAssets()
        settings.onSpritesChanged = { [weak self] in
            self?.reloadAssets()
        }
    }

    public func reloadAssets() {
        var newCache: [PetState: [NSImage]] = [:]

        // 1. Idle
        if let customIdle = settings.customIdlePath, let img = NSImage(contentsOfFile: customIdle) {
            newCache[.idle] = [img]
        } else {
            newCache[.idle] = loadDefaultImages(named: ["Idle.png"])
        }

        // 2. Walk Left
        if !settings.customWalkLeftPaths.isEmpty {
            let customImgs = settings.customWalkLeftPaths.compactMap { NSImage(contentsOfFile: $0) }
            newCache[.walkLeft] = !customImgs.isEmpty ? customImgs : loadDefaultImages(named: ["left1.png", "left2.png"])
        } else {
            newCache[.walkLeft] = loadDefaultImages(named: ["left1.png", "left2.png"])
        }

        // 3. Walk Right
        if !settings.customWalkRightPaths.isEmpty {
            let customImgs = settings.customWalkRightPaths.compactMap { NSImage(contentsOfFile: $0) }
            newCache[.walkRight] = !customImgs.isEmpty ? customImgs : loadDefaultImages(named: ["right1.png", "right2.png"])
        } else {
            newCache[.walkRight] = loadDefaultImages(named: ["right1.png", "right2.png"])
        }

        // 4. Falling
        if let customFall = settings.customFallPath, let img = NSImage(contentsOfFile: customFall) {
            newCache[.falling] = [img]
        } else {
            newCache[.falling] = loadDefaultImages(named: ["Fall.png"])
        }

        // 5. Dragged usa lo sprite di caduta
        newCache[.dragged] = newCache[.falling] ?? newCache[.idle]

        self.cache = newCache
    }

    public func images(for state: PetState) -> [NSImage] {
        if let imgs = cache[state], !imgs.isEmpty {
            return imgs
        }
        // Fallback estremo a Idle
        return cache[.idle] ?? []
    }

    /// Trova e carica le immagini cercandole nel Bundle .app o nella cartella di progetto locale
    private func loadDefaultImages(named names: [String]) -> [NSImage] {
        return names.compactMap { name -> NSImage? in
            // Tentativo 1: Bundle.main / Resources / Assets Stellina
            if let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "Assets Stellina"),
               let img = NSImage(contentsOf: url) {
                return img
            }

            // Tentativo 2: Bundle.main resourceURL diretto
            if let resURL = Bundle.main.resourceURL?.appendingPathComponent("Assets Stellina").appendingPathComponent(name),
               let img = NSImage(contentsOf: resURL) {
                return img
            }

            // Tentativo 3: Cartella locale durante sviluppo (Assets Stellina nella root di lavoro)
            let localPath = "Assets Stellina/\(name)"
            if FileManager.default.fileExists(atPath: localPath),
               let img = NSImage(contentsOfFile: localPath) {
                return img
            }

            // Tentativo 4: Bundle.module per SPM se disponibile
            #if SWIFT_PACKAGE
            if let moduleURL = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Assets Stellina"),
               let img = NSImage(contentsOf: moduleURL) {
                return img
            }
            if let moduleURL = Bundle.module.url(forResource: name, withExtension: nil),
               let img = NSImage(contentsOf: moduleURL) {
                return img
            }
            #endif

            // Tentativo 5: Fallback su percorso interno del bundle
            if let directResURL = Bundle.main.resourceURL?.appendingPathComponent(name),
               let img = NSImage(contentsOf: directResURL) {
                return img
            }

            return nil
        }
    }
}
