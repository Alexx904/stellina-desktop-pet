import AppKit
import QuartzCore

public final class PetView: NSView {
    private var dragStartWindowOrigin: NSPoint = .zero
    private var dragStartMouseLocation: NSPoint = .zero
    private let behavior = BehaviorSystem.shared

    private var trackingArea: NSTrackingArea?
    private var lastMouseX: CGFloat = 0
    private var strokeCount: Int = 0
    private var lastDirection: Int = 0
    private var lastStrokeTime: TimeInterval = 0

    // Layer dedicati per separazione netta tra sprite del pet e overlay della mano
    private let spriteLayer = CALayer()
    private let headpatLayer = CALayer()
    private var isHeadpatActive: Bool = false

    public var onOpenSettingsRequested: (() -> Void)?

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
        setupContextMenu()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupContextMenu()
    }

    private func setupLayers() {
        wantsLayer = true
        guard let rootLayer = self.layer else { return }
        rootLayer.backgroundColor = NSColor.clear.cgColor

        // 1. Sprite del Pet: anchor point alla base (0.5, 0.0) per deformazioni naturali a terra
        spriteLayer.contentsGravity = .resizeAspect
        spriteLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        spriteLayer.zPosition = 10
        rootLayer.addSublayer(spriteLayer)

        // 2. Overlay mano pat-pat: sopra il pet, centrata sulla testa
        headpatLayer.contentsGravity = .resizeAspect
        headpatLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        headpatLayer.opacity = 0.0
        headpatLayer.zPosition = 50
        rootLayer.addSublayer(headpatLayer)

        updateSublayerLayout()
    }

    override public func layout() {
        super.layout()
        updateSublayerLayout()
    }

    private func updateSublayerLayout() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let w = bounds.width
        let h = bounds.height

        // Stellina poggia sulla base (y = 0 in coordinate standard AppKit)
        spriteLayer.bounds = CGRect(x: 0, y: 0, width: w, height: h)
        spriteLayer.position = CGPoint(x: w / 2.0, y: 0.0)

        // Mano pat-pat posizionata sulla sommità della testa
        let handSize = w * 0.75
        headpatLayer.bounds = CGRect(x: 0, y: 0, width: handSize, height: handSize)
        headpatLayer.position = CGPoint(x: w * 0.5, y: h * 0.72)

        CATransaction.commit()
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
        spriteLayer.contents = image
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

        if abs(dx) > 4.0 {
            let direction = dx > 0 ? 1 : -1
            if direction != lastDirection && (now - lastStrokeTime) < 0.7 {
                strokeCount += 1
                if strokeCount >= 2 {
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
        spriteLayer.transform = CATransform3DMakeScale(0.9, 1.15, 1.0)
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
        spriteLayer.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    // MARK: - Animazione Headpat (GIF Mano + Deformazione Squish & Bend)

    public func startHeadpatAnimation() {
        spawnHeartParticles()

        if !isHeadpatActive {
            isHeadpatActive = true

            // 1. Carica e applica la GIF della mano a headpatLayer
            if let gif = AssetManager.shared.loadGIF(named: "headpat-hand.gif"), !gif.frames.isEmpty {
                let frameAnim = CAKeyframeAnimation(keyPath: "contents")
                frameAnim.values = gif.frames
                frameAnim.duration = gif.totalDuration > 0 ? gif.totalDuration : 0.35
                frameAnim.repeatCount = .infinity
                frameAnim.isRemovedOnCompletion = false
                headpatLayer.add(frameAnim, forKey: "headpatHandFrames")
            }

            // Mostra la mano con fade-in
            let fadeIn = CABasicAnimation(keyPath: "opacity")
            fadeIn.fromValue = headpatLayer.opacity
            fadeIn.toValue = 1.0
            fadeIn.duration = 0.15
            headpatLayer.add(fadeIn, forKey: "headpatFadeIn")
            headpatLayer.opacity = 1.0

            // 2. Deformazione Squish & Bend sincronizzata di Stellina
            // Sfrutta anchorPoint (0.5, 0.0) per schiacciare Stellina verso il basso e piegarla dolcemente
            let squishBendAnim = CAKeyframeAnimation(keyPath: "transform")

            let normalTransform = CATransform3DIdentity

            // Schiacciamento con leggera flessione laterale (bend)
            var bendLeft = CATransform3DMakeScale(1.14, 0.82, 1.0)
            bendLeft = CATransform3DRotate(bendLeft, -0.04, 0, 0, 1)

            var bendRight = CATransform3DMakeScale(1.12, 0.84, 1.0)
            bendRight = CATransform3DRotate(bendRight, 0.03, 0, 0, 1)

            let bounceTransform = CATransform3DMakeScale(0.97, 1.03, 1.0)

            squishBendAnim.values = [
                NSValue(caTransform3D: normalTransform),
                NSValue(caTransform3D: bendLeft),
                NSValue(caTransform3D: normalTransform),
                NSValue(caTransform3D: bendRight),
                NSValue(caTransform3D: bounceTransform),
                NSValue(caTransform3D: normalTransform)
            ]
            squishBendAnim.keyTimes = [0.0, 0.25, 0.5, 0.75, 0.9, 1.0]
            squishBendAnim.duration = 0.70 // Due cicli di carezza per battuta
            squishBendAnim.repeatCount = .infinity
            squishBendAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            squishBendAnim.isRemovedOnCompletion = false

            spriteLayer.add(squishBendAnim, forKey: "petSquishBend")
        }
    }

    public func stopHeadpatAnimation() {
        guard isHeadpatActive else { return }
        isHeadpatActive = false

        // 1. Fade-out dell'overlay della mano
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.duration = 0.25
        headpatLayer.add(fadeOut, forKey: "headpatFadeOut")
        headpatLayer.opacity = 0.0
        CATransaction.commit()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self, !self.isHeadpatActive else { return }
            self.headpatLayer.removeAnimation(forKey: "headpatHandFrames")
        }

        // 2. Rilascio elastico morbido di Stellina alla forma normale
        spriteLayer.removeAnimation(forKey: "petSquishBend")
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        spriteLayer.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    // MARK: - Effetti Procedurali (Atterraggio, Risveglio, Particelle)

    public func triggerSquishBounce() {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values = [1.0, 1.25, 0.85, 1.05, 1.0]
        anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        anim.duration = 0.3
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        spriteLayer.add(anim, forKey: "squishBounce")
    }

    public func triggerHop() {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.y")
        anim.values = [0.0, 20.0, 0.0]
        anim.keyTimes = [0.0, 0.5, 1.0]
        anim.duration = 0.25
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        spriteLayer.add(anim, forKey: "hop")
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
                heartLayer.zPosition = 100
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

    public func spawnZzzParticle() {
        guard let rootLayer = self.layer else { return }

        let zzzTextLayer = CATextLayer()
        let texts = ["z", "Zz", "ZzZz", "💤"]
        zzzTextLayer.string = texts.randomElement() ?? "ZzZz"
        zzzTextLayer.fontSize = CGFloat.random(in: 15...20)
        zzzTextLayer.alignmentMode = .center
        zzzTextLayer.foregroundColor = NSColor(calibratedRed: 0.45, green: 0.55, blue: 0.95, alpha: 0.9).cgColor
        zzzTextLayer.zPosition = 100

        let startX = (bounds.width / 2.0) + CGFloat.random(in: -15...20)
        let startY = bounds.height * 0.65
        zzzTextLayer.frame = CGRect(x: startX, y: startY, width: 44, height: 26)

        rootLayer.addSublayer(zzzTextLayer)

        let duration: CFTimeInterval = 1.4

        let moveYAnim = CABasicAnimation(keyPath: "position.y")
        moveYAnim.fromValue = startY
        moveYAnim.toValue = startY + CGFloat.random(in: 35...60)

        let moveXAnim = CABasicAnimation(keyPath: "position.x")
        moveXAnim.fromValue = startX
        moveXAnim.toValue = startX + CGFloat.random(in: -15...25)

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 1.0
        fadeAnim.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [moveYAnim, moveXAnim, fadeAnim]
        group.duration = duration
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        zzzTextLayer.add(group, forKey: "zzzFloat")

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            zzzTextLayer.removeFromSuperlayer()
        }
    }
}
