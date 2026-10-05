import AppKit

public final class StatusBarController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var sleepMenuItem: NSMenuItem?
    private var needsMenuItem: NSMenuItem?
    private var accessoryMenuItem: NSMenuItem?
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

        // Sottomenu Accessori
        let accItem = NSMenuItem(title: "Accessorio sulla Testa", action: nil, keyEquivalent: "")
        let accSubmenu = NSMenu()
        for acc in PetAccessory.allCases {
            let item = NSMenuItem(title: acc.displayName, action: #selector(selectAccessoryAction(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = acc
            accSubmenu.addItem(item)
        }
        accItem.submenu = accSubmenu
        self.accessoryMenuItem = accItem
        menu.addItem(accItem)

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

        // Segna con spunta l'accessorio attivo
        if let sub = accessoryMenuItem?.submenu {
            let current = PetSettings.shared.equippedAccessory
            for item in sub.items {
                if let acc = item.representedObject as? PetAccessory {
                    item.state = (acc == current) ? .on : .off
                }
            }
        }
    }

    @objc private func selectAccessoryAction(_ sender: NSMenuItem) {
        if let acc = sender.representedObject as? PetAccessory {
            PetSettings.shared.equippedAccessory = acc
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
