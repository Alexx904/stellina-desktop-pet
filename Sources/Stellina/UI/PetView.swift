import AppKit

public final class PetView: NSView {
    private var dragStartWindowOrigin: NSPoint = .zero
    private var dragStartMouseLocation: NSPoint = .zero
    private let behavior = BehaviorSystem.shared

    private var trackingArea: NSTrackingArea?
    private var lastMouseX: CGFloat = 0
    private var strokeCount: Int = 0
    private var lastDirection: Int = 0
    private var lastStrokeTime: TimeInterval = 0

    public var onOpenSettingsRequested: (() -> Void)?

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
        setupContextMenu()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
        setupContextMenu()
    }

    private func setupLayer() {
        wantsLayer = true
        layer?.contentsGravity = .resizeAspect
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    override public func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        self.trackingArea = area
    }

    public func setSpriteImage(_ image: NSImage?) {
        guard let image = image else { return }
        layer?.contents = image
    }

    private func setupContextMenu() {
        let menu = NSMenu()

        let petItem = NSMenuItem(title: "Fai le Coccole 💖", action: #selector(patAction), keyEquivalent: "p")
        petItem.target = self
        menu.addItem(petItem)

        let settingsItem = NSMenuItem(title: "Impostazioni...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let resetPosItem = NSMenuItem(title: "Riposiziona al Centro", action: #selector(resetPositionAction), keyEquivalent: "r")
        resetPosItem.target = self
        menu.addItem(resetPosItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Chiudi Stellina", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        self.menu = menu
    }

    @objc private func patAction() {
        behavior.pet()
    }

    @objc private func openSettingsAction() {
        onOpenSettingsRequested?()
    }

    @objc private func resetPositionAction() {
        behavior.resetToInitialPosition()
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Gestures & Pat-Pat Detection

    override public func mouseEntered(with event: NSEvent) {
        if behavior.currentState == .sleeping {
            behavior.wakeUp()
        }
    }

    override public func mouseMoved(with event: NSEvent) {
        behavior.resetInactivity()
        if behavior.currentState == .sleeping {
            behavior.wakeUp()
            return
        }

        let currentX = event.locationInWindow.x
        let dx = currentX - lastMouseX
        let now = Date().timeIntervalSince1970

        if abs(dx) > 5.0 {
            let direction = dx > 0 ? 1 : -1
            if direction != lastDirection && (now - lastStrokeTime) < 0.6 {
                strokeCount += 1
                if strokeCount >= 3 {
                    strokeCount = 0
                    behavior.pet()
                }
            } else if (now - lastStrokeTime) > 0.8 {
                strokeCount = 1
            }
            lastDirection = direction
            lastStrokeTime = now
            lastMouseX = currentX
        }
    }

    // MARK: - Native Mouse Drag & Drop

    override public func mouseDown(with event: NSEvent) {
        guard let window = self.window else { return }
        behavior.isDragging = true
        dragStartWindowOrigin = window.frame.origin
        dragStartMouseLocation = NSEvent.mouseLocation

        // Stretch elastico cartoon quando viene presa
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.15)
        layer?.transform = CATransform3DMakeScale(0.9, 1.15, 1.0)
        CATransaction.commit()
    }

    override public func mouseDragged(with event: NSEvent) {
        guard let window = self.window else { return }
        let currentMouse = NSEvent.mouseLocation
        let deltaX = currentMouse.x - dragStartMouseLocation.x
        let deltaY = currentMouse.y - dragStartMouseLocation.y

        let newOrigin = NSPoint(
            x: dragStartWindowOrigin.x + deltaX,
            y: dragStartWindowOrigin.y + deltaY
        )

        behavior.setManualPosition(x: Double(newOrigin.x), y: Double(newOrigin.y))
        window.setFrameOrigin(newOrigin)
    }

    override public func mouseUp(with event: NSEvent) {
        behavior.endDrag()

        // Ritorno alla forma originale
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.15)
        layer?.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    // MARK: - Effetti Procedurali (Squish, Wobble, Particelle)

    public func triggerSquishBounce() {
        guard let layer = self.layer else { return }
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values = [1.0, 1.25, 0.85, 1.05, 1.0]
        anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        anim.duration = 0.3
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(anim, forKey: "squishBounce")
    }

    public func triggerPetPatEffect() {
        triggerPurrWobble()
        spawnHeartParticles()
    }

    public func triggerHop() {
        guard let layer = self.layer else { return }
        let anim = CAKeyframeAnimation(keyPath: "position.y")
        let originY = layer.position.y
        anim.values = [originY, originY + 18, originY]
        anim.keyTimes = [0.0, 0.5, 1.0]
        anim.duration = 0.25
        layer.add(anim, forKey: "hop")
    }

    private func triggerPurrWobble() {
        guard let layer = self.layer else { return }
        let anim = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        anim.values = [0.0, -0.06, 0.06, -0.04, 0.04, 0.0]
        anim.duration = 0.35
        layer.add(anim, forKey: "purrWobble")
    }

    private func spawnHeartParticles() {
        guard let rootLayer = self.layer else { return }

        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) { [weak self] in
                guard let self = self, let root = self.layer else { return }

                let heartLayer = CATextLayer()
                heartLayer.string = "❤️"
                heartLayer.fontSize = 20
                heartLayer.alignmentMode = .center
                let startX = CGFloat.random(in: 20...(self.bounds.width - 40))
                let startY = CGFloat.random(in: 30...(self.bounds.height - 30))
                heartLayer.frame = CGRect(x: startX, y: startY, width: 28, height: 28)

                root.addSublayer(heartLayer)

                // Animazione di salita e dissolvenza
                let moveAnim = CABasicAnimation(keyPath: "position.y")
                moveAnim.fromValue = startY
                moveAnim.toValue = startY + CGFloat.random(in: 40...70)
                moveAnim.duration = 0.8

                let fadeAnim = CABasicAnimation(keyPath: "opacity")
                fadeAnim.fromValue = 1.0
                fadeAnim.toValue = 0.0
                fadeAnim.duration = 0.8

                let group = CAAnimationGroup()
                group.animations = [moveAnim, fadeAnim]
                group.duration = 0.8
                group.isRemovedOnCompletion = false
                group.fillMode = .forwards

                heartLayer.add(group, forKey: "heartFloat")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    heartLayer.removeFromSuperlayer()
                }
            }
        }
    }
}
