import AppKit

public final class StatusBarController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var sleepMenuItem: NSMenuItem?
    private var needsMenuItem: NSMenuItem?
    private var foodMenuItem: NSMenuItem?
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

        let appTitle = NSMenuItem(title: "🐾 Stellina Desktop Pet v1.1", action: nil, keyEquivalent: "")
        appTitle.isEnabled = false
        menu.addItem(appTitle)

        let authorItem = NSMenuItem(title: "Ideato da Alessandro Miniello ✨", action: nil, keyEquivalent: "")
        authorItem.isEnabled = false
        menu.addItem(authorItem)

        let needsItem = NSMenuItem(title: "💖 Coccole: 100% | \(PetSettings.shared.selectedFood.emoji) Sazietà: 100%", action: nil, keyEquivalent: "")
        needsItem.isEnabled = false
        self.needsMenuItem = needsItem
        menu.addItem(needsItem)

        menu.addItem(NSMenuItem.separator())

        let sleepItem = NSMenuItem(title: "Metti a Dormire 💤", action: #selector(toggleSleepAction), keyEquivalent: "s")
        sleepItem.target = self
        self.sleepMenuItem = sleepItem
        menu.addItem(sleepItem)

        let curFood = PetSettings.shared.selectedFood
        let foodItem = NSMenuItem(title: "Lancia \(curFood.displayName) \(curFood.emoji)", action: #selector(spawnCarrotAction), keyEquivalent: "c")
        foodItem.target = self
        self.foodMenuItem = foodItem
        menu.addItem(foodItem)

        // Sottomenu Cibi
        let foodsMenu = NSMenu()
        for f in FoodType.allCases {
            let item = NSMenuItem(title: "\(f.emoji) \(f.displayName)", action: #selector(selectFoodAction(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = f.rawValue
            foodsMenu.addItem(item)
        }
        let chooseFoodItem = NSMenuItem(title: "Scegli Snack...", action: nil, keyEquivalent: "")
        chooseFoodItem.submenu = foodsMenu
        menu.addItem(chooseFoodItem)

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
            sleepMenuItem?.title = "Sveglia \(PetSettings.shared.selectedCharacter.displayName) ☀️"
        } else {
            sleepMenuItem?.title = "Metti a Dormire 💤"
        }

        let curFood = PetSettings.shared.selectedFood
        foodMenuItem?.title = "Lancia \(curFood.displayName) \(curFood.emoji)"

        if PetSettings.shared.gamificationEnabled {
            needsMenuItem?.isHidden = false
            let aff = Int(PetNeedsManager.shared.affection)
            let full = Int(PetNeedsManager.shared.fullness)
            needsMenuItem?.title = "💖 Coccole: \(aff)% | \(curFood.emoji) Sazietà: \(full)%"
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

    @objc private func selectFoodAction(_ sender: NSMenuItem) {
        if let raw = sender.representedObject as? String, let f = FoodType(rawValue: raw) {
            PetSettings.shared.selectedFood = f
            CarrotManager.shared.spawnCarrot(foodType: f)
        }
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
