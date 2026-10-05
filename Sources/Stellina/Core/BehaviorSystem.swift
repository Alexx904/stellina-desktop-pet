import AppKit
import Foundation

public final class BehaviorSystem {
    public static let shared = BehaviorSystem()

    private let settings = PetSettings.shared
    private let physics = PhysicsSystem.shared
    private let assetManager = AssetManager.shared

    // Stato di simulazione
    public private(set) var currentState: PetState = .falling
    public private(set) var posX: Double = 0.0
    public private(set) var posY: Double = 0.0
    public private(set) var velocityY: Double = 0.0

    public var isDragging: Bool = false {
        didSet {
            if isDragging {
                currentState = .dragged
                velocityY = 0.0
                animIndex = 0
                resetInactivity()
                SoundManager.shared.play(.dragStart)
            }
        }
    }

    private var walkTicksRemaining: Int = 0
    private var pettedTicksRemaining: Int = 0
    private var inactivityTicks: Int = 0
    private var sleepZzzTickCounter: Int = 0
    private var animIndex: Int = 0
    private var animTickCounter: Int = 0

    public var onFrameUpdate: ((NSImage?, CGPoint) -> Void)?
    public var onLanded: (() -> Void)?
    public var onPetPatTriggered: (() -> Void)?
    public var onPetPatEnded: (() -> Void)?
    public var onWakeUpTriggered: (() -> Void)?
    public var onSleepZzzTriggered: (() -> Void)?

    private init() {
        resetToInitialPosition()
    }

    public func resetInactivity() {
        inactivityTicks = 0
    }

    public func pet() {
        guard settings.petPatEnabled else { return }
        resetInactivity()
        if currentState == .sleeping {
            wakeUp()
            return
        }
        let wasAlreadyPetted = (currentState == .petted)
        currentState = .petted
        pettedTicksRemaining = 60 // ~2 secondi di coccole
        if !wasAlreadyPetted {
            SoundManager.shared.play(.patPat)
        }
        onPetPatTriggered?()
    }

    public func wakeUp() {
        guard currentState == .sleeping else { return }
        currentState = .idle
        resetInactivity()
        walkTicksRemaining = 60
        SoundManager.shared.play(.wakeUp)
        onWakeUpTriggered?()
    }

    public func resetToInitialPosition() {
        let frame = physics.currentScreenFrame
        let size = settings.windowSize
        posX = Double(frame.origin.x) + (Double(frame.size.width) - size) / 2.0
        posY = Double(frame.origin.y + frame.size.height) - size // Inizia in alto e cade
        velocityY = 0.0
        currentState = .falling
        walkTicksRemaining = 0
        pettedTicksRemaining = 0
        inactivityTicks = 0
        animIndex = 0
        animTickCounter = 0
    }

    public func setManualPosition(x: Double, y: Double) {
        posX = x
        posY = y
        velocityY = 0.0
        resetInactivity()
    }

    public func endDrag() {
        isDragging = false
        resetInactivity()
        if posY > physics.groundY {
            currentState = .falling
        } else {
            currentState = .idle
            walkTicksRemaining = Int.random(in: 60...150)
        }
        animIndex = 0
    }

    public func tick() {
        let size = settings.windowSize

        if isDragging {
            // Durante il drag la posizione viene gestita direttamente dagli eventi mouse
            currentState = .dragged
            resetInactivity()
        } else {
            // Gestione gravitazionale
            if posY > physics.groundY {
                currentState = .falling
                physics.applyGravity(posY: &posY, velocityY: &velocityY) { [weak self] in
                    guard let self = self else { return }
                    self.currentState = .idle
                    self.walkTicksRemaining = Int.random(in: 60...150)
                    self.animIndex = 0
                    SoundManager.shared.play(.land)
                    self.onLanded?()
                }
            } else {
                posY = physics.groundY
                velocityY = 0.0

                if currentState == .petted {
                    // Stato coccolato
                    pettedTicksRemaining -= 1
                    if pettedTicksRemaining <= 0 {
                        currentState = .idle
                        walkTicksRemaining = Int.random(in: 50...100)
                        onPetPatEnded?()
                    }
                } else if currentState == .sleeping {
                    // Emette l'effetto grafico Zzz periodicamente (~1 volta al secondo)
                    sleepZzzTickCounter += 1
                    if sleepZzzTickCounter >= 30 {
                        sleepZzzTickCounter = 0
                        onSleepZzzTriggered?()
                    }
                } else {
                    sleepZzzTickCounter = 0
                    // Controllo inattività per addormentarsi
                    inactivityTicks += 1
                    let sleepThresholdTicks = Int(settings.sleepIdleSeconds * 30)
                    if settings.sleepEnabled && inactivityTicks >= sleepThresholdTicks {
                        currentState = .sleeping
                    }

                    // Movimento orizzontale a terra
                    if currentState != .sleeping {
                        if walkTicksRemaining > 0 {
                            walkTicksRemaining -= 1
                            let speed = settings.walkSpeed
                            if currentState == .walkRight {
                                posX += speed
                            } else if currentState == .walkLeft {
                                posX -= speed
                            }

                            // Rimbalzo sui bordi schermo
                            physics.handleHorizontalBounds(
                                posX: &posX,
                                windowWidth: size,
                                currentState: &currentState
                            )
                        } else {
                            // Selezione nuova azione casuale
                            let rand = Int.random(in: 1...3)
                            switch rand {
                            case 1:
                                currentState = .idle
                            case 2:
                                currentState = .walkRight
                            default:
                                currentState = .walkLeft
                            }
                            walkTicksRemaining = Int.random(in: 60...160)
                            animIndex = 0
                        }
                    }
                }
            }
        }

        // Avanzamento animazione frame
        animTickCounter += 1
        let currentImages = assetManager.images(for: currentState)
        if animTickCounter >= settings.animSpeedTicks {
            animTickCounter = 0
            if !currentImages.isEmpty {
                animIndex = (animIndex + 1) % currentImages.count
            }
        }

        let currentImage: NSImage?
        if !currentImages.isEmpty {
            currentImage = currentImages[animIndex % currentImages.count]
        } else {
            currentImage = nil
        }

        onFrameUpdate?(currentImage, CGPoint(x: posX, y: posY))
    }
}
