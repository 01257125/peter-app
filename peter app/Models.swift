import SwiftUI

// MARK: - Team Side
enum TeamSide: String, Codable, CaseIterable {
    case myTeam = "我方"
    case opponent = "對手"
}

// MARK: - Tactics Mode (戰術模式: 攻擊戰術 / 3人接發球)
enum TacticsMode: String, Codable, CaseIterable, Identifiable {
    case attack = "攻擊戰術"
    case serveReceive = "3人接發球"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .attack: return "bolt.circle.fill"
        case .serveReceive: return "shield.inset.filled"
        }
    }
}

// MARK: - Player Role
enum PlayerRole: String, Codable, CaseIterable {
    case setter = "舉球員 (S)"
    case outside1 = "主攻手 (OH1)"
    case outside2 = "主攻手 (OH2)"
    case middle1 = "副攻/快攻 (MB1)"
    case middle2 = "副攻/快攻 (MB2)"
    case opposite = "對角/舉對 (OP)"
    case libero = "自由球員 (L)"
    
    var shortCode: String {
        switch self {
        case .setter: return "S"
        case .outside1: return "OH1"
        case .outside2: return "OH2"
        case .middle1: return "MB1"
        case .middle2: return "MB2"
        case .opposite: return "OP"
        case .libero: return "L"
        }
    }
    
    var color: Color {
        switch self {
        case .setter: return .purple
        case .outside1, .outside2: return .orange
        case .middle1, .middle2: return .blue
        case .opposite: return .red
        case .libero: return .yellow
        }
    }
}

// MARK: - Attack Type
enum AttackType: String, Codable, CaseIterable, Identifiable {
    case spike4 = "4號位強攻 (High Left)"
    case quickA = "A快攻 (Short Quick)"
    case quickB = "B快攻 (Medium Quick)"
    case spike2 = "2號位背飛/強攻 (Right Attack)"
    case pipe = "後排Pipe攻擊 (Back Center)"
    case tip = "吊球 (Tip/Drop)"
    case block = "攔網防守 (Block)"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .spike4: return "arrow.up.left.and.arrow.down.right"
        case .quickA: return "bolt.fill"
        case .quickB: return "bolt"
        case .spike2: return "arrow.up.right"
        case .pipe: return "arrow.up"
        case .tip: return "hand.tap.fill"
        case .block: return "shield.fill"
        }
    }
}

// MARK: - Player Dummy Position Model
struct PlayerPosition: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var number: Int // 1 to 6 position
    var name: String
    var role: PlayerRole
    var team: TeamSide
    var normalizedX: Double // 0.0 ~ 1.0 on court
    var normalizedY: Double // 0.0 ~ 1.0 on court (0.0 top, 1.0 bottom)
    var isAttacker: Bool = false
    
    // Default rotation positions (1-6) for My Team (Bottom half: y 0.52 to 0.95)
    static func defaultMyTeamPositions() -> [PlayerPosition] {
        return [
            // 1號位: 後排右
            PlayerPosition(number: 1, name: "1號位 (後右)", role: .opposite, team: .myTeam, normalizedX: 0.80, normalizedY: 0.85),
            // 2號位: 前排右
            PlayerPosition(number: 2, name: "2號位 (前右)", role: .setter, team: .myTeam, normalizedX: 0.75, normalizedY: 0.58),
            // 3號位: 前排中
            PlayerPosition(number: 3, name: "3號位 (前中)", role: .middle1, team: .myTeam, normalizedX: 0.50, normalizedY: 0.58),
            // 4號位: 前排左
            PlayerPosition(number: 4, name: "4號位 (前左)", role: .outside1, team: .myTeam, normalizedX: 0.25, normalizedY: 0.58),
            // 5號位: 後排左
            PlayerPosition(number: 5, name: "5號位 (後左)", role: .outside2, team: .myTeam, normalizedX: 0.20, normalizedY: 0.85),
            // 6號位: 後排中
            PlayerPosition(number: 6, name: "6號位 (後中)", role: .libero, team: .myTeam, normalizedX: 0.50, normalizedY: 0.88)
        ]
    }
    
    // Default positions (1-6) for Opponent Team (Top half: y 0.05 to 0.48)
    static func defaultOpponentPositions() -> [PlayerPosition] {
        return [
            // 1號位: 後排右 (Top perspective)
            PlayerPosition(number: 1, name: "對手 1號位", role: .outside1, team: .opponent, normalizedX: 0.20, normalizedY: 0.15),
            // 2號位: 前排右
            PlayerPosition(number: 2, name: "對手 2號位", role: .middle1, team: .opponent, normalizedX: 0.25, normalizedY: 0.42),
            // 3號位: 前排中
            PlayerPosition(number: 3, name: "對手 3號位", role: .setter, team: .opponent, normalizedX: 0.50, normalizedY: 0.42),
            // 4號位: 前排左
            PlayerPosition(number: 4, name: "對手 4號位", role: .opposite, team: .opponent, normalizedX: 0.75, normalizedY: 0.42),
            // 5號位: 後排左
            PlayerPosition(number: 5, name: "對手 5號位", role: .outside2, team: .opponent, normalizedX: 0.80, normalizedY: 0.15),
            // 6號位: 後排中
            PlayerPosition(number: 6, name: "對手 6號位", role: .libero, team: .opponent, normalizedX: 0.50, normalizedY: 0.12)
        ]
    }
}

// MARK: - Tactical Formation Record
struct TacticalFormation: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String = ""
    var dateCreated: Date = Date()
    var myPlayers: [PlayerPosition]
    var opponentPlayers: [PlayerPosition]
    var selectedAttackerNumber: Int?
    var attackType: AttackType = .spike4
    var attackTargetX: Double = 0.5
    var attackTargetY: Double = 0.25
}
