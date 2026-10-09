import AppKit
import QuartzCore

public final class CarrotView: NSView {
    public weak var carrotWindow: CarrotWindow?

    private let emojiLayer = CATextLayer()
    private var dragStartWindowOrigin: NSPoint = .zero
    private var dragStartMouseLocation: NSPoint = .zero

    public var isDragging: Bool = false
    public var onDragChanged: ((NSPoint) -> Void)?
    public var onDragEnded: (() -> Void)?

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    public var foodType: FoodType = .carrot {
        didSet {
            emojiLayer.string = foodType.emoji
        }
    }

    public convenience init(frame frameRect: NSRect, foodType: FoodType = .carrot) {
        self.init(frame: frameRect)
        self.foodType = foodType
        self.emojiLayer.string = foodType.emoji
    }

    private func setupLayers() {
        wantsLayer = true
        guard let root = self.layer else { return }
        root.backgroundColor = NSColor.clear.cgColor

        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        emojiLayer.contentsScale = scale
        emojiLayer.string = foodType.emoji
        emojiLayer.fontSize = 36
        emojiLayer.alignmentMode = .center
        emojiLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        emojiLayer.zPosition = 10


        // Leggera ombra morbida per dare rilievo
        emojiLayer.shadowColor = NSColor.black.withAlphaComponent(0.35).cgColor
        emojiLayer.shadowOpacity = 0.4
        emojiLayer.shadowOffset = CGSize(width: 0, height: -2)
        emojiLayer.shadowRadius = 3

        root.addSublayer(emojiLayer)
        updateLayout()
    }

    override public func layout() {
        super.layout()
        updateLayout()
    }

    private func updateLayout() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        emojiLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        emojiLayer.position = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        CATransaction.commit()
    }

    // MARK: - Drag & Drop

    override public func mouseDown(with event: NSEvent) {
        guard let window = self.window else { return }
        isDragging = true
        dragStartWindowOrigin = window.frame.origin
        dragStartMouseLocation = NSEvent.mouseLocation

        // Effetto elastico e leggera inclinazione quando presa
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.12)
        var t = CATransform3DMakeScale(1.15, 1.15, 1.0)
        t = CATransform3DRotate(t, 0.15, 0, 0, 1)
        emojiLayer.transform = t
        CATransaction.commit()

        SoundManager.shared.play(.dragStart)
    }

    override public func mouseDragged(with event: NSEvent) {
        guard let window = self.window, isDragging else { return }
        let currentMouse = NSEvent.mouseLocation
        let deltaX = currentMouse.x - dragStartMouseLocation.x
        let deltaY = currentMouse.y - dragStartMouseLocation.y

        let newOrigin = NSPoint(
            x: dragStartWindowOrigin.x + deltaX,
            y: dragStartWindowOrigin.y + deltaY
        )

        window.setFrameOrigin(newOrigin)
        onDragChanged?(newOrigin)
    }

    override public func mouseUp(with event: NSEvent) {
        guard isDragging else { return }
        isDragging = false

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.12)
        emojiLayer.transform = CATransform3DIdentity
        CATransaction.commit()

        onDragEnded?()
    }

    // MARK: - Animazioni (Atterraggio e Consumazione)

    public func triggerLandingSquish() {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values = [1.0, 1.28, 0.88, 1.05, 1.0]
        anim.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        anim.duration = 0.25
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        emojiLayer.add(anim, forKey: "carrotLandingSquish")
    }

    public func animateEaten(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setCompletionBlock {
            completion()
        }

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 0.0
        scaleAnim.duration = 0.25
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 1.0
        fadeAnim.toValue = 0.0
        fadeAnim.duration = 0.25

        let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnim.fromValue = 0.0
        rotateAnim.toValue = Double.pi
        rotateAnim.duration = 0.25

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, fadeAnim, rotateAnim]
        group.duration = 0.25
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        emojiLayer.add(group, forKey: "eatCarrotAnim")
        CATransaction.commit()
    }
}
