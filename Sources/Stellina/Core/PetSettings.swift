import Foundation
import Combine

public final class PetSettings: ObservableObject {
    public static let shared = PetSettings()

    private enum Keys {
        static let windowSize = "stellina_window_size"
        static let walkSpeed = "stellina_walk_speed"
        static let gravity = "stellina_gravity"
        static let animSpeedTicks = "stellina_anim_speed_ticks"
        static let customIdlePath = "stellina_custom_idle"
        static let customWalkLeftPaths = "stellina_custom_walk_left"
        static let customWalkRightPaths = "stellina_custom_walk_right"
        static let customFallPath = "stellina_custom_fall"
        static let customSleepPath = "stellina_custom_sleep"

        // Audio & Interazioni
        static let soundEnabled = "stellina_sound_enabled"
        static let soundVolume = "stellina_sound_volume"
        static let petPatEnabled = "stellina_petpat_enabled"
        static let sleepEnabled = "stellina_sleep_enabled"
        static let sleepIdleSeconds = "stellina_sleep_idle_seconds"
    }

    // Parametri Fisici e Visivi
    @Published public var windowSize: Double {
        didSet { UserDefaults.standard.set(windowSize, forKey: Keys.windowSize) }
    }

    @Published public var walkSpeed: Double {
        didSet { UserDefaults.standard.set(walkSpeed, forKey: Keys.walkSpeed) }
    }

    @Published public var gravity: Double {
        didSet { UserDefaults.standard.set(gravity, forKey: Keys.gravity) }
    }

    @Published public var animSpeedTicks: Int {
        didSet { UserDefaults.standard.set(animSpeedTicks, forKey: Keys.animSpeedTicks) }
    }

    // Audio & Interazioni
    @Published public var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled) }
    }

    @Published public var soundVolume: Double {
        didSet { UserDefaults.standard.set(soundVolume, forKey: Keys.soundVolume) }
    }

    @Published public var petPatEnabled: Bool {
        didSet { UserDefaults.standard.set(petPatEnabled, forKey: Keys.petPatEnabled) }
    }

    @Published public var sleepEnabled: Bool {
        didSet { UserDefaults.standard.set(sleepEnabled, forKey: Keys.sleepEnabled) }
    }

    @Published public var sleepIdleSeconds: Double {
        didSet { UserDefaults.standard.set(sleepIdleSeconds, forKey: Keys.sleepIdleSeconds) }
    }

    // Percorsi Sprite Personalizzati
    @Published public var customIdlePath: String? {
        didSet {
            UserDefaults.standard.set(customIdlePath, forKey: Keys.customIdlePath)
            onSpritesChanged?()
        }
    }

    @Published public var customWalkLeftPaths: [String] {
        didSet {
            UserDefaults.standard.set(customWalkLeftPaths, forKey: Keys.customWalkLeftPaths)
            onSpritesChanged?()
        }
    }

    @Published public var customWalkRightPaths: [String] {
        didSet {
            UserDefaults.standard.set(customWalkRightPaths, forKey: Keys.customWalkRightPaths)
            onSpritesChanged?()
        }
    }

    @Published public var customFallPath: String? {
        didSet {
            UserDefaults.standard.set(customFallPath, forKey: Keys.customFallPath)
            onSpritesChanged?()
        }
    }

    @Published public var customSleepPath: String? {
        didSet {
            UserDefaults.standard.set(customSleepPath, forKey: Keys.customSleepPath)
            onSpritesChanged?()
        }
    }

    /// Callback invocato quando gli sprite cambiano per consentire l'hot-reload
    public var onSpritesChanged: (() -> Void)?

    private init() {
        let defaults = UserDefaults.standard

        let savedSize = defaults.double(forKey: Keys.windowSize)
        self.windowSize = savedSize > 0 ? savedSize : 150.0

        let savedSpeed = defaults.double(forKey: Keys.walkSpeed)
        self.walkSpeed = savedSpeed > 0 ? savedSpeed : 4.0

        let savedGravity = defaults.double(forKey: Keys.gravity)
        self.gravity = savedGravity > 0 ? savedGravity : 2.0

        let savedAnimTicks = defaults.integer(forKey: Keys.animSpeedTicks)
        self.animSpeedTicks = savedAnimTicks > 0 ? savedAnimTicks : 5

        self.soundEnabled = defaults.object(forKey: Keys.soundEnabled) != nil ? defaults.bool(forKey: Keys.soundEnabled) : true
        let savedVol = defaults.double(forKey: Keys.soundVolume)
        self.soundVolume = savedVol > 0 ? savedVol : 0.8
        self.petPatEnabled = defaults.object(forKey: Keys.petPatEnabled) != nil ? defaults.bool(forKey: Keys.petPatEnabled) : true
        self.sleepEnabled = defaults.object(forKey: Keys.sleepEnabled) != nil ? defaults.bool(forKey: Keys.sleepEnabled) : true
        let savedSleepIdle = defaults.double(forKey: Keys.sleepIdleSeconds)
        self.sleepIdleSeconds = savedSleepIdle > 0 ? savedSleepIdle : 120.0

        self.customIdlePath = defaults.string(forKey: Keys.customIdlePath)
        self.customWalkLeftPaths = defaults.stringArray(forKey: Keys.customWalkLeftPaths) ?? []
        self.customWalkRightPaths = defaults.stringArray(forKey: Keys.customWalkRightPaths) ?? []
        self.customFallPath = defaults.string(forKey: Keys.customFallPath)
        self.customSleepPath = defaults.string(forKey: Keys.customSleepPath)
    }

    public func resetToDefaults() {
        windowSize = 150.0
        walkSpeed = 4.0
        gravity = 2.0
        animSpeedTicks = 5

        soundEnabled = true
        soundVolume = 0.8
        petPatEnabled = true
        sleepEnabled = true
        sleepIdleSeconds = 120.0

        customIdlePath = nil
        customWalkLeftPaths = []
        customWalkRightPaths = []
        customFallPath = nil
        customSleepPath = nil

        UserDefaults.standard.removeObject(forKey: Keys.windowSize)
        UserDefaults.standard.removeObject(forKey: Keys.walkSpeed)
        UserDefaults.standard.removeObject(forKey: Keys.gravity)
        UserDefaults.standard.removeObject(forKey: Keys.animSpeedTicks)
        UserDefaults.standard.removeObject(forKey: Keys.soundEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.soundVolume)
        UserDefaults.standard.removeObject(forKey: Keys.petPatEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.sleepEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.sleepIdleSeconds)
        UserDefaults.standard.removeObject(forKey: Keys.customIdlePath)
        UserDefaults.standard.removeObject(forKey: Keys.customWalkLeftPaths)
        UserDefaults.standard.removeObject(forKey: Keys.customWalkRightPaths)
        UserDefaults.standard.removeObject(forKey: Keys.customFallPath)
        UserDefaults.standard.removeObject(forKey: Keys.customSleepPath)

        onSpritesChanged?()
    }
}
