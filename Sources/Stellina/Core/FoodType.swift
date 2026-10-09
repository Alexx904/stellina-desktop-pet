import Foundation

/// Tipologie di cibo e snack selezionabili da lanciare al pet
public enum FoodType: String, CaseIterable, Identifiable {
    case carrot = "carrot"
    case bone = "bone"
    case fish = "fish"
    case meat = "meat"
    case cheese = "cheese"
    case apple = "apple"
    case cookie = "cookie"

    public var id: String { rawValue }

    /// Nome visualizzato dell'alimento
    public var displayName: String {
        switch self {
        case .carrot:
            return "Carota"
        case .bone:
            return "Osso"
        case .fish:
            return "Pesce"
        case .meat:
            return "Bistecca"
        case .cheese:
            return "Formaggio"
        case .apple:
            return "Mela"
        case .cookie:
            return "Biscotto"
        }
    }

    /// Emoji renderizzata a schermo per il cibo
    public var emoji: String {
        switch self {
        case .carrot:
            return "🥕"
        case .bone:
            return "🦴"
        case .fish:
            return "🐟"
        case .meat:
            return "🥩"
        case .cheese:
            return "🧀"
        case .apple:
            return "🍎"
        case .cookie:
            return "🍪"
        }
    }

    /// Set di particelle fluttuanti durante l'animazione di masticazione
    public var particles: [String] {
        switch self {
        case .carrot:
            return ["🥕", "🔸", "✨", "🧡", "🥕"]
        case .bone:
            return ["🦴", "🤍", "✨", "🦴", "🐶"]
        case .fish:
            return ["🐟", "🫧", "✨", "💙", "🐟"]
        case .meat:
            return ["🥩", "🍖", "✨", "❤️", "🥩"]
        case .cheese:
            return ["🧀", "💛", "✨", "🧀", "🧀"]
        case .apple:
            return ["🍎", "🔴", "✨", "🍏", "🍎"]
        case .cookie:
            return ["🍪", "🟤", "✨", "⭐", "🍪"]
        }
    }
}
