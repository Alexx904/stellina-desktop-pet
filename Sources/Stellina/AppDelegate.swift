import AppKit
import Combine

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindow: PetWindow?
    private var petView: PetView?
    private var statusBarController: StatusBarController?
    private var simulationTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private let behavior = BehaviorSystem.shared
    private let settings = PetSettings.shared

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Modalità accessoria: non mostra l'icona nel Dock
        NSApp.setActivationPolicy(.accessory)

        // 2. Inizializza StatusBar (icona 🐾)
        statusBarController = StatusBarController()
        statusBarController?.onOpenSettingsRequested = {
            SettingsWindowController.shared.showSettings()
        }

        // 3. Inizializza la finestra del Pet
        let initialSize = settings.windowSize
        let initialRect = NSRect(
            x: behavior.posX,
            y: behavior.posY,
            width: initialSize,
            height: initialSize
        )

        let window = PetWindow(contentRect: initialRect)
        let view = PetView(frame: NSRect(x: 0, y: 0, width: initialSize, height: initialSize))
        view.onOpenSettingsRequested = {
            SettingsWindowController.shared.showSettings()
        }

        window.contentView = view
        window.makeKeyAndOrderFront(nil)

        self.petWindow = window
        self.petView = view

        // 4. Collega il motore di simulazione al rendering della vista
        behavior.onFrameUpdate = { [weak self] image, point in
            guard let self = self, let win = self.petWindow else { return }
            self.petView?.setSpriteImage(image)

            // Se non stiamo trascinando, aggiorna la posizione della finestra calcolata dalla fisica
            if !self.behavior.isDragging {
                win.setFrameOrigin(NSPoint(x: point.x, y: point.y))
            }
        }

        behavior.onLanded = { [weak self] in
            self?.petView?.triggerSquishBounce()
        }

        behavior.onPetPatTriggered = { [weak self] in
            self?.petView?.startHeadpatAnimation()
        }

        behavior.onPetPatEnded = { [weak self] in
            self?.petView?.stopHeadpatAnimation()
        }

        behavior.onWakeUpTriggered = { [weak self] in
            self?.petView?.triggerHop()
        }

        behavior.onSleepZzzTriggered = { [weak self] in
            self?.petView?.spawnZzzParticle()
        }

        behavior.onEatTriggered = { [weak self] in
            self?.petView?.triggerEatAnimation()
        }

        // 5. Ascolta modifiche delle dimensioni dalle impostazioni
        settings.$windowSize
            .receive(on: RunLoop.main)
            .sink { [weak self] newSize in
                guard let self = self, let win = self.petWindow else { return }
                let currentOrigin = win.frame.origin
                let newFrame = NSRect(x: currentOrigin.x, y: currentOrigin.y, width: newSize, height: newSize)
                win.setFrame(newFrame, display: true, animate: false)
                self.petView?.frame = NSRect(x: 0, y: 0, width: newSize, height: newSize)
            }
            .store(in: &cancellables)

        // 6. Avvia il loop di simulazione (~30 FPS / 0.033s)
        startSimulationLoop()
    }

    private func startSimulationLoop() {
        simulationTimer?.invalidate()
        let timer = Timer(timeInterval: 0.033, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.behavior.tick()
            if let petFrame = self.petWindow?.frame {
                CarrotManager.shared.tick(petFrame: petFrame)
            }
            PetNeedsManager.shared.tick(deltaTime: 0.033)
        }
        RunLoop.main.add(timer, forMode: .common)
        self.simulationTimer = timer
    }

    public func applicationWillTerminate(_ notification: Notification) {
        simulationTimer?.invalidate()
        CarrotManager.shared.removeAllCarrots()
    }
}
