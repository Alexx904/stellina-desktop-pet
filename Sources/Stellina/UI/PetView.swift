import AppKit

public final class PetView: NSView {
    private var dragStartWindowOrigin: NSPoint = .zero
    private var dragStartMouseLocation: NSPoint = .zero
    private let behavior = BehaviorSystem.shared

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

    public func setSpriteImage(_ image: NSImage?) {
        guard let image = image else { return }
        layer?.contents = image
    }

    private func setupContextMenu() {
        let menu = NSMenu()

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

    @objc private func openSettingsAction() {
        onOpenSettingsRequested?()
    }

    @objc private func resetPositionAction() {
        behavior.resetToInitialPosition()
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Native Mouse Drag & Drop

    override public func mouseDown(with event: NSEvent) {
        guard let window = self.window else { return }
        behavior.isDragging = true
        dragStartWindowOrigin = window.frame.origin
        dragStartMouseLocation = NSEvent.mouseLocation
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
    }
}
