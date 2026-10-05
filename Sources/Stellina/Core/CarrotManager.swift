import AppKit
import Foundation

public final class CarrotManager {
    public static let shared = CarrotManager()

    public final class CarrotItem {
        public let window: CarrotWindow
        public let view: CarrotView
        public var posX: Double
        public var posY: Double
        public var velocityY: Double
        public var isFalling: Bool
        public var isBeingEaten: Bool

        public init(window: CarrotWindow, view: CarrotView, posX: Double, posY: Double) {
            self.window = window
            self.view = view
            self.posX = posX
            self.posY = posY
            self.velocityY = 0.0
            self.isFalling = true
            self.isBeingEaten = false
        }
    }

    private var activeCarrots: [CarrotItem] = []
    private let physics = PhysicsSystem.shared
    private let settings = PetSettings.shared

    public static let carrotSize: CGFloat = 52.0
    private let maxCarrots: Int = 3

    // Spawning casuale periodico (in ticks, ~30 FPS -> 180s = ~5400 ticks)
    private var autoSpawnTickCounter: Int = 0
    private let autoSpawnIntervalTicks: Int = 30 * 180 // ogni 3 minuti

    public var onFeedPet: (() -> Void)?

    private init() {}

    public func spawnCarrot(at customPoint: NSPoint? = nil) {
        // Rimuove la carota più vecchia se si supera il limite di 3 carote a schermo
        if activeCarrots.count >= maxCarrots, let oldest = activeCarrots.first {
            removeCarrot(oldest)
        }

        let frame = physics.currentScreenFrame
        let size = Self.carrotSize

        let startX: Double
        let startY: Double

        if let pt = customPoint {
            startX = Double(pt.x)
            startY = Double(pt.y)
        } else {
            // Coordinate casuali sicure sullo schermo
            let minSpawnX = Double(frame.origin.x) + 30.0
            let maxSpawnX = Double(frame.origin.x + frame.size.width) - Double(size) - 30.0
            startX = Double.random(in: min(minSpawnX, maxSpawnX)...max(minSpawnX, maxSpawnX))

            // Spawna nella parte alta dello schermo
            let screenTop = Double(frame.origin.y + frame.size.height)
            startY = screenTop - Double(size) - Double.random(in: 40...160)
        }

        let carrotRect = NSRect(x: startX, y: startY, width: size, height: size)
        let window = CarrotWindow(contentRect: carrotRect)
        let view = CarrotView(frame: NSRect(x: 0, y: 0, width: size, height: size))
        view.carrotWindow = window
        window.contentView = view

        let item = CarrotItem(window: window, view: view, posX: startX, posY: startY)

        view.onDragChanged = { [weak self, weak item] newOrigin in
            guard let self = self, let item = item else { return }
            item.posX = Double(newOrigin.x)
            item.posY = Double(newOrigin.y)
            item.velocityY = 0.0
            item.isFalling = (item.posY > self.physics.groundY)
        }

        view.onDragEnded = { [weak self, weak item] in
            guard let self = self, let item = item else { return }
            if item.posY > self.physics.groundY {
                item.isFalling = true
            } else {
                item.posY = self.physics.groundY
                item.isFalling = false
            }
        }

        activeCarrots.append(item)
        window.makeKeyAndOrderFront(nil)
        SoundManager.shared.play(.carrotSpawn)
    }

    public func tick(petFrame: NSRect) {
        // Gestione spawn periodico casuale automatico
        autoSpawnTickCounter += 1
        if autoSpawnTickCounter >= autoSpawnIntervalTicks {
            autoSpawnTickCounter = 0
            if activeCarrots.count < maxCarrots {
                spawnCarrot()
            }
        }

        let gY = physics.groundY
        let currentGravity = settings.gravity

        var carrotsToEat: [CarrotItem] = []

        for item in activeCarrots where !item.isBeingEaten {
            let carrotFrame = item.window.frame

            // 1. Controllo di prossimità/collisione con Stellina
            let petCenter = CGPoint(x: petFrame.midX, y: petFrame.midY)
            let carrotCenter = CGPoint(x: carrotFrame.midX, y: carrotFrame.midY)
            let distance = hypot(Double(petCenter.x - carrotCenter.x), Double(petCenter.y - carrotCenter.y))

            if distance < 75.0 || carrotFrame.intersects(petFrame) {
                carrotsToEat.append(item)
                continue
            }

            // 2. Fisica di caduta se non viene trascinata dall'utente
            if !item.view.isDragging && item.isFalling {
                if item.posY > gY {
                    item.velocityY -= currentGravity
                    item.posY += item.velocityY
                    if item.posY <= gY {
                        item.posY = gY
                        item.velocityY = 0.0
                        item.isFalling = false
                        item.view.triggerLandingSquish()
                        SoundManager.shared.play(.land)
                    }
                } else {
                    item.posY = gY
                    item.velocityY = 0.0
                    item.isFalling = false
                }
                item.window.setFrameOrigin(NSPoint(x: item.posX, y: item.posY))
            }
        }

        // Nutri Stellina con le carote che sono entrate in contatto
        for item in carrotsToEat {
            feedPet(with: item)
        }
    }

    private func feedPet(with item: CarrotItem) {
        guard !item.isBeingEaten else { return }
        item.isBeingEaten = true

        item.view.animateEaten { [weak self, weak item] in
            guard let self = self, let item = item else { return }
            self.removeCarrot(item)
        }

        BehaviorSystem.shared.feed()
        onFeedPet?()
    }

    private func removeCarrot(_ item: CarrotItem) {
        item.window.orderOut(nil)
        item.window.close()
        activeCarrots.removeAll { $0 === item }
    }

    public func removeAllCarrots() {
        for item in activeCarrots {
            item.window.orderOut(nil)
            item.window.close()
        }
        activeCarrots.removeAll()
    }
}
