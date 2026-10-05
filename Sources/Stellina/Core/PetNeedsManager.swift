import Foundation
import Combine

public final class PetNeedsManager: ObservableObject {
    public static let shared = PetNeedsManager()

    private enum Keys {
        static let affection = "stellina_affection_level"
        static let fullness = "stellina_fullness_level"
        static let lastSaveTimestamp = "stellina_needs_last_save_time"
    }

    private let settings = PetSettings.shared

    public static let lowThreshold: Double = 25.0

    @Published public private(set) var affection: Double = 100.0 {
        didSet {
            let wasLow = isAffectionLow
            isAffectionLow = affection < Self.lowThreshold
            if wasLow != isAffectionLow {
                notifyAlertState()
            }
        }
    }

    @Published public private(set) var fullness: Double = 100.0 {
        didSet {
            let wasLow = isFullnessLow
            isFullnessLow = fullness < Self.lowThreshold
            if wasLow != isFullnessLow {
                notifyAlertState()
            }
        }
    }

    @Published public private(set) var isAffectionLow: Bool = false
    @Published public private(set) var isFullnessLow: Bool = false

    public var onNeedsChanged: (() -> Void)?
    public var onNeedsStatusAlert: ((_ lowAffection: Bool, _ lowFullness: Bool) -> Void)?

    private var tickAccumulator: Double = 0.0

    private init() {
        let defaults = UserDefaults.standard
        let savedAff = defaults.object(forKey: Keys.affection) != nil ? defaults.double(forKey: Keys.affection) : 100.0
        let savedFull = defaults.object(forKey: Keys.fullness) != nil ? defaults.double(forKey: Keys.fullness) : 100.0
        
        self.affection = min(100.0, max(0.0, savedAff))
        self.fullness = min(100.0, max(0.0, savedFull))
        self.isAffectionLow = self.affection < Self.lowThreshold
        self.isFullnessLow = self.fullness < Self.lowThreshold

        // Calcola decadimento lieve per il tempo trascorso a riposo (max 20% di decadimento offline)
        if let lastTime = defaults.object(forKey: Keys.lastSaveTimestamp) as? Date {
            let elapsedMinutes = Date().timeIntervalSince(lastTime) / 60.0
            if elapsedMinutes > 5.0 {
                let affDrop = min(25.0, (elapsedMinutes / settings.affectionDecayMinutes) * 15.0)
                let fullDrop = min(30.0, (elapsedMinutes / settings.hungerDecayMinutes) * 15.0)
                self.affection = max(10.0, self.affection - affDrop)
                self.fullness = max(10.0, self.fullness - fullDrop)
                self.isAffectionLow = self.affection < Self.lowThreshold
                self.isFullnessLow = self.fullness < Self.lowThreshold
            }
        }
    }

    /// Aggiornamento decadimento bisogni a intervalli temporali
    public func tick(deltaTime: Double) {
        guard settings.gamificationEnabled else { return }

        // Decadimento Affetto (Coccole)
        let affDecayRatePerSecond = 100.0 / (settings.affectionDecayMinutes * 60.0)
        let newAff = max(0.0, affection - (affDecayRatePerSecond * deltaTime))

        // Decadimento Sazietà (Fame)
        let hungerDecayRatePerSecond = 100.0 / (settings.hungerDecayMinutes * 60.0)
        let newFull = max(0.0, fullness - (hungerDecayRatePerSecond * deltaTime))

        if abs(newAff - affection) > 0.001 || abs(newFull - fullness) > 0.001 {
            affection = newAff
            fullness = newFull
            onNeedsChanged?()
        }

        tickAccumulator += deltaTime
        if tickAccumulator >= 10.0 {
            tickAccumulator = 0.0
            saveState()
        }
    }

    /// Ricarica coccole/affetto
    public func pet(amount: Double = 14.0) {
        guard settings.gamificationEnabled else { return }
        affection = min(100.0, affection + amount)
        saveState()
        onNeedsChanged?()
    }

    /// Ricarica sazietà con una carota
    public func feed(amount: Double = 40.0) {
        guard settings.gamificationEnabled else { return }
        fullness = min(100.0, fullness + amount)
        saveState()
        onNeedsChanged?()
    }

    public func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(affection, forKey: Keys.affection)
        defaults.set(fullness, forKey: Keys.fullness)
        defaults.set(Date(), forKey: Keys.lastSaveTimestamp)
    }

    public func resetNeeds() {
        affection = 100.0
        fullness = 100.0
        isAffectionLow = false
        isFullnessLow = false
        saveState()
        onNeedsChanged?()
        notifyAlertState()
    }

    private func notifyAlertState() {
        guard settings.gamificationEnabled else {
            onNeedsStatusAlert?(false, false)
            return
        }
        onNeedsStatusAlert?(isAffectionLow, isFullnessLow)
    }
}

