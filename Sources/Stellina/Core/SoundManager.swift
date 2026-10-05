import AppKit
import Foundation

public enum SoundEffect {
    case patPat
    case land
    case dragStart
    case wakeUp
    case hop
}

public final class SoundManager {
    public static let shared = SoundManager()

    private let settings = PetSettings.shared

    private init() {}

    public func play(_ effect: SoundEffect) {
        guard settings.soundEnabled else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
