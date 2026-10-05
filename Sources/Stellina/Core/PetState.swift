import Foundation

public enum PetState: String, CaseIterable, Codable {
    case idle = "idle"
    case walkLeft = "walkLeft"
    case walkRight = "walkRight"
    case falling = "falling"
    case dragged = "dragged"

    public var displayName: String {
        switch self {
        case .idle: return "Inattivo (Idle)"
        case .walkLeft: return "Cammina a Sinistra"
        case .walkRight: return "Cammina a Destra"
        case .falling: return "In Caduta"
        case .dragged: return "Trascinato"
        }
    }
}
