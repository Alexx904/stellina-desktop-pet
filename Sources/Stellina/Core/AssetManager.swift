import AppKit
import Foundation
import ImageIO

public final class AssetManager {
    public static let shared = AssetManager()

    private var cache: [PetState: [NSImage]] = [:]
    private var gifCache: [String: (frames: [CGImage], frameDuration: Double, totalDuration: Double)] = [:]
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

        // 6. Sleeping (Sleep.png)
        if let customSleep = settings.customSleepPath, let img = NSImage(contentsOfFile: customSleep) {
            newCache[.sleeping] = [img]
        } else {
            let loaded = loadDefaultImages(named: ["Sleep.png"])
            newCache[.sleeping] = !loaded.isEmpty ? loaded : newCache[.idle]
        }

        // 7. Petted usa lo sprite idle (la mano gif e lo squish vengono sovrapposti da PetView)
        newCache[.petted] = newCache[.idle]

        self.cache = newCache
    }

    public func images(for state: PetState) -> [NSImage] {
        if let imgs = cache[state], !imgs.isEmpty {
            return imgs
        }
        // Fallback estremo a Idle
        return cache[.idle] ?? []
    }

    /// Risolve il percorso URL di un asset cercandolo nel Bundle .app o nella cartella di sviluppo locale
    public func urlForAsset(named name: String, character: PetCharacter? = nil) -> URL? {
        let activeChar = character ?? settings.selectedCharacter
        let dirName = activeChar.assetDirectoryName

        // Tentativo 1: Sotto-cartella del personaggio nel Resources del Bundle .app
        if let url = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: dirName) {
            return url
        }

        // Tentativo 2: Percorso diretto sotto Resources/<dirName>
        if let resURL = Bundle.main.resourceURL?.appendingPathComponent(dirName).appendingPathComponent(name),
           FileManager.default.fileExists(atPath: resURL.path) {
            return resURL
        }

        // Tentativo 3: Cartella locale radice durante sviluppo / 'make run' / 'swift run'
        let localPath = "\(dirName)/\(name)"
        if FileManager.default.fileExists(atPath: localPath) {
            return URL(fileURLWithPath: localPath)
        }

        // Fallback su "Assets Stellina" se non trovato nella cartella del personaggio corrente
        if dirName != "Assets Stellina" {
            if let fallbackURL = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: "Assets Stellina") {
                return fallbackURL
            }
            if let resFallback = Bundle.main.resourceURL?.appendingPathComponent("Assets Stellina").appendingPathComponent(name),
               FileManager.default.fileExists(atPath: resFallback.path) {
                return resFallback
            }
            let fallbackLocal = "Assets Stellina/\(name)"
            if FileManager.default.fileExists(atPath: fallbackLocal) {
                return URL(fileURLWithPath: fallbackLocal)
            }
        }

        // Tentativo generico nel Bundle .app
        if let url = Bundle.main.url(forResource: name, withExtension: nil) {
            return url
        }

        return nil
    }


    /// Decodifica e indicizza i fotogrammi CGImage di una GIF animata tramite ImageIO
    public func loadGIF(named name: String) -> (frames: [CGImage], frameDuration: Double, totalDuration: Double)? {
        if let cached = gifCache[name] {
            return cached
        }

        guard let url = urlForAsset(named: name),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }

        var frames: [CGImage] = []
        var totalDuration: Double = 0.0
        var avgFrameDuration: Double = 0.07

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                frames.append(cgImage)

                var frameDelay = 0.07
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
                   let gifProps = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
                    if let unclamped = gifProps[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0.01 {
                        frameDelay = unclamped
                    } else if let delay = gifProps[kCGImagePropertyGIFDelayTime] as? Double, delay > 0.01 {
                        frameDelay = delay
                    }
                }
                totalDuration += frameDelay
            }
        }

        if !frames.isEmpty {
            avgFrameDuration = totalDuration / Double(frames.count)
        }

        let result = (frames: frames, frameDuration: avgFrameDuration, totalDuration: totalDuration)
        gifCache[name] = result
        return result
    }

    private func loadDefaultImages(named names: [String]) -> [NSImage] {
        return names.compactMap { name -> NSImage? in
            guard let url = urlForAsset(named: name) else { return nil }
            return NSImage(contentsOf: url)
        }
    }
}
