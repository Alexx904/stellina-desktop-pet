import Foundation

/// Personaggi standard selezionabili per il Desktop Pet
public enum PetCharacter: String, CaseIterable, Identifiable {
    case bunny = "bunny"
    case dog = "dog"
    case cat = "cat"

    public var id: String { rawValue }

    /// Nome visualizzato nell'interfaccia utente
    public var displayName: String {
        switch self {
        case .bunny:
            return "Stellina (Coniglietto)"
        case .dog:
            return "Cagnolino"
        case .cat:
            return "Gattino"
        }
    }

    /// Emoji rappresentativa del personaggio
    public var emoji: String {
        switch self {
        case .bunny:
            return "🐰"
        case .dog:
            return "🐶"
        case .cat:
            return "🐱"
        }
    }

    /// Cartella contenente gli sprite di default del personaggio
    public var assetDirectoryName: String {
        switch self {
        case .bunny:
            return "Assets Stellina"
        case .dog:
            return "Assets Cane"
        case .cat:
            return "Assets Gatto"
        }
    }

    /// Cibo naturale preferito associato al personaggio
    public var defaultFood: FoodType {
        switch self {
        case .bunny:
            return .carrot
        case .dog:
            return .bone
        case .cat:
            return .fish
        }
    }
}
