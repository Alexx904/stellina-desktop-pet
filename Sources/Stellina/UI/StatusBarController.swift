import AppKit

public final class StatusBarController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var sleepMenuItem: NSMenuItem?
    private var needsMenuItem: NSMenuItem?
    public var onOpenSettingsRequested: (() -> Void)?

    override public init() {
        super.init()
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title = "🐾"
            button.toolTip = "Stellina Desktop Pet"
        }

        let menu = NSMenu()
        menu.delegate = self

        let appTitle = NSMenuItem(title: "🐾 Stellina Desktop Pet v1.0", action: nil, keyEquivalent: "")
        appTitle.isEnabled = false
        menu.addItem(appTitle)

        let needsItem = NSMenuItem(title: "💖 Coccole: 100% | 🥕 Sazietà: 100%", action: nil, keyEquivalent: "")
        needsItem.isEnabled = false
        self.needsMenuItem = needsItem
        menu.addItem(needsItem)

        menu.addItem(NSMenuItem.separator())

        let sleepItem = NSMenuItem(title: "Metti a Dormire 💤", action: #selector(toggleSleepAction), keyEquivalent: "s")
        sleepItem.target = self
        self.sleepMenuItem = sleepItem
        menu.addItem(sleepItem)

        let carrotItem = NSMenuItem(title: "Lancia Carota 🥕", action: #selector(spawnCarrotAction), keyEquivalent: "c")
        carrotItem.target = self
        menu.addItem(carrotItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Impostazioni...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let resetPosItem = NSMenuItem(title: "Riposiziona al Centro", action: #selector(resetPositionAction), keyEquivalent: "r")
        resetPosItem.target = self
        menu.addItem(resetPosItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Esci da Stellina", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
        if BehaviorSystem.shared.currentState == .sleeping {
            sleepMenuItem?.title = "Sveglia Stellina ☀️"
        } else {
            sleepMenuItem?.title = "Metti a Dormire 💤"
        }

        if PetSettings.shared.gamificationEnabled {
            needsMenuItem?.isHidden = false
            let aff = Int(PetNeedsManager.shared.affection)
            let full = Int(PetNeedsManager.shared.fullness)
            needsMenuItem?.title = "💖 Coccole: \(aff)% | 🥕 Sazietà: \(full)%"
        } else {
            needsMenuItem?.isHidden = true
        }
    }

    @objc private func toggleSleepAction() {
        BehaviorSystem.shared.toggleSleep()
    }

    @objc private func spawnCarrotAction() {
        CarrotManager.shared.spawnCarrot()
    }

    @objc private func openSettingsAction() {
        onOpenSettingsRequested?()
    }

    @objc private func resetPositionAction() {
        BehaviorSystem.shared.resetToInitialPosition()
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
