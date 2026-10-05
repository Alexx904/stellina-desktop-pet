import AppKit
import Foundation

public enum SoundEffect {
    case patPat
    case land
    case dragStart
    case wakeUp
    case hop
    case carrotSpawn
    case eat
}

public final class SoundManager {
    public static let shared = SoundManager()

    private let settings = PetSettings.shared

    private init() {}

    public func play(_ effect: SoundEffect) {
        guard settings.soundEnabled else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if effect == .eat {
                // Effetto sonoro croccante e sequenziale di masticazione (3 morsi cartoon ravvicinati)
                let bites = ["Pop", "Purr", "Pop"]
                for (index, biteName) in bites.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.09) {
                        if let sound = NSSound(named: biteName) {
                            sound.volume = Float(self.settings.soundVolume)
                            sound.play()
                        }
                    }
                }
                return
            }

            let soundName: String
            switch effect {
            case .patPat:
                // Tenta un suono morbido di fusa/pop
                soundName = "Purr"
            case .land:
                soundName = "Bottle"
            case .dragStart:
                soundName = "Pop"
            case .wakeUp:
                soundName = "Tink"
            case .hop:
                soundName = "Hero"
            case .carrotSpawn:
                soundName = "Bottle"
            case .eat:
                soundName = "Pop"
            }

            if let sound = NSSound(named: soundName) {
                sound.volume = Float(self.settings.soundVolume)
                sound.stop()
                sound.play()
            } else {
                // Fallback sul suono di sistema generico
                NSSound.beep()
            }
        }
    }
}
