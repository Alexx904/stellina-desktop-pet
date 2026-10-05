import AppKit
import Foundation

public final class PhysicsSystem {
    public static let shared = PhysicsSystem()

    private let settings = PetSettings.shared

    public init() {}

    /// Restituisce l'area visibile sicura dello schermo principale (esclude Dock e Barra Menu)
    public var currentScreenFrame: NSRect {
        if let mainScreen = NSScreen.main {
            return mainScreen.visibleFrame
        }
        return NSScreen.screens.first?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
    }

    public var groundY: Double {
        return Double(currentScreenFrame.origin.y)
    }

    public var minX: Double {
        return Double(currentScreenFrame.origin.x)
    }

    public func maxX(windowWidth: Double) -> Double {
        return Double(currentScreenFrame.origin.x + currentScreenFrame.size.width) - windowWidth
    }

    /// Calcola la fisica di gravità per il frame corrente
    public func applyGravity(
        posY: inout Double,
        velocityY: inout Double,
        onLanded: () -> Void
    ) {
        let gY = groundY
        let currentGravity = settings.gravity

        if posY > gY {
            velocityY -= currentGravity
            posY += velocityY
            if posY <= gY {
                posY = gY
                velocityY = 0.0
                onLanded()
            }
        } else {
            posY = gY
            velocityY = 0.0
        }
    }

    /// Rileva e gestisce il rimbalzo sui margini laterali dello schermo
    public func handleHorizontalBounds(
        posX: inout Double,
        windowWidth: Double,
        currentState: inout PetState
    ) {
        let leftLimit = minX
        let rightLimit = maxX(windowWidth: windowWidth)

        if posX < leftLimit {
            posX = leftLimit
            if currentState == .walkLeft {
                currentState = .walkRight
            }
        } else if posX > rightLimit {
            posX = rightLimit
            if currentState == .walkRight {
                currentState = .walkLeft
            }
        }
    }
}
