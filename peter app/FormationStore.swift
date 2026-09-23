import SwiftUI
import Combine
import AudioToolbox

@MainActor
class FormationStore: ObservableObject {
    @Published var myPlayers: [PlayerPosition] = PlayerPosition.defaultMyTeamPositions()
    @Published var opponentPlayers: [PlayerPosition] = PlayerPosition.defaultOpponentPositions()
    
    @Published var tacticsMode: TacticsMode = .attack // 戰術模式: 攻擊戰術 / 3人接發球
    
    @Published var selectedAttackerNumber: Int? = 4 // Default attacker: 4號位 (前左)
    @Published var selectedAttackType: AttackType = .spike4 {
        didSet {
            playSpikeSound()
        }
    }
    @Published var attackTargetX: Double = 0.35
    @Published var attackTargetY: Double = 0.20
    
    @Published var isSoundEnabled: Bool = false // 扣球音效 (預設關閉)
    
    @Published var savedFormations: [TacticalFormation] = []
    @Published var activeFormationName: String = "預設排球陣型"
    
    // 自訂戰術觀念與教練筆記 (可自由修改)
    @Published var customTacticalNotes: [String] = [
        "1. 前排快攻掩護：3號位中間快攻吸引對手防守攔網，開闢4號位大斜角叩擊通道。",
        "2. 後排 Pipe 攻擊：6號位從三米線後跳起發動後排強攻，搭配前排假快攻擾亂對手。",
        "3. 3人接發球要領：由兩位大砲 (OH1, OH2) 與自由球員 (L) 形成半月弧線，舉球員 (S) 網前插上舉球。"
    ]
    
    private let userDefaultsKey = "SavedVolleyballFormations_v1"
    
    init() {
        loadSavedFormations()
        if savedFormations.isEmpty {
            createPresetFormations()
        }
    }
    
    // MARK: - Sound Effect
    func playSpikeSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1057)
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        if isSoundEnabled {
            playSpikeSound()
        }
    }
    
    // MARK: - Switch Tactics Mode (切換攻擊/3人接發球模式)
    func setTacticsMode(_ mode: TacticsMode) {
        tacticsMode = mode
        if mode == .serveReceive {
            apply3PersonReceiveFormation()
        }
    }
    
    // 3人接發球站位自動拉出弧線 (OH1, L, OH2 涵蓋後場，S 網前插上)
    func apply3PersonReceiveFormation() {
        // 我方 3人接發站位
        for i in myPlayers.indices {
            let role = myPlayers[i].role
            switch role {
            case .outside1:
                myPlayers[i].normalizedX = 0.20
                myPlayers[i].normalizedY = 0.82
            case .libero:
                myPlayers[i].normalizedX = 0.50
                myPlayers[i].normalizedY = 0.88
            case .outside2:
                myPlayers[i].normalizedX = 0.80
                myPlayers[i].normalizedY = 0.82
            case .setter:
                myPlayers[i].normalizedX = 0.70
                myPlayers[i].normalizedY = 0.55 // 網前準備插上舉球
            case .middle1, .middle2:
                myPlayers[i].normalizedX = 0.45
                myPlayers[i].normalizedY = 0.53 // 網前準備快攻
            case .opposite:
                myPlayers[i].normalizedX = 0.15
                myPlayers[i].normalizedY = 0.55 // 避開接發
            }
        }
        
        // 對手 3人接發站位 (上半場)
        for i in opponentPlayers.indices {
            let role = opponentPlayers[i].role
            switch role {
            case .outside1:
                opponentPlayers[i].normalizedX = 0.80
                opponentPlayers[i].normalizedY = 0.18
            case .libero:
                opponentPlayers[i].normalizedX = 0.50
                opponentPlayers[i].normalizedY = 0.12
            case .outside2:
                opponentPlayers[i].normalizedX = 0.20
                opponentPlayers[i].normalizedY = 0.18
            case .setter:
                opponentPlayers[i].normalizedX = 0.30
                opponentPlayers[i].normalizedY = 0.45
            case .middle1, .middle2:
                opponentPlayers[i].normalizedX = 0.55
                opponentPlayers[i].normalizedY = 0.47
            case .opposite:
                opponentPlayers[i].normalizedX = 0.85
                opponentPlayers[i].normalizedY = 0.45
            }
        }
        
        activeFormationName = "3人接發球陣型 (W弧線)"
    }
    
    // MARK: - Update Player Name (自訂隊員名字)
    func updatePlayerName(number: Int, newName: String) {
        if let idx = myPlayers.firstIndex(where: { $0.number == number }) {
            myPlayers[idx].name = newName
        }
    }
    
    // MARK: - Attacker Helpers
    var currentAttacker: PlayerPosition? {
        guard let num = selectedAttackerNumber else { return nil }
        return myPlayers.first(where: { $0.number == num })
    }
    
    func setAttacker(number: Int) {
        selectedAttackerNumber = number
        for i in myPlayers.indices {
            myPlayers[i].isAttacker = (myPlayers[i].number == number)
        }
        playSpikeSound()
    }
    
    // MARK: - Player Drag Updates (雙方假人皆可自由拖移)
    func updatePlayerPosition(id: UUID, newX: Double, newY: Double, isMyTeam: Bool) {
        let clampedX = min(max(newX, 0.05), 0.95)
        if isMyTeam {
            let clampedY = min(max(newY, 0.51), 0.96)
            if let index = myPlayers.firstIndex(where: { $0.id == id }) {
                myPlayers[index].normalizedX = clampedX
                myPlayers[index].normalizedY = clampedY
            }
        } else {
            let clampedY = min(max(newY, 0.04), 0.49)
            if let index = opponentPlayers.firstIndex(where: { $0.id == id }) {
                opponentPlayers[index].normalizedX = clampedX
                opponentPlayers[index].normalizedY = clampedY
            }
        }
    }
    
    // MARK: - Rotation (順時針輪轉: 1 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1)
    func rotateMyTeamClockwise() {
        let numbers = [1, 6, 5, 4, 3, 2]
        var oldPosMap: [Int: (Double, Double)] = [:]
        for p in myPlayers {
            oldPosMap[p.number] = (p.normalizedX, p.normalizedY)
        }
        
        for i in 0..<numbers.count {
            let fromNum = numbers[i]
            let toNum = numbers[(i + 1) % numbers.count]
            if let targetIdx = myPlayers.firstIndex(where: { $0.number == toNum }),
               let oldPos = oldPosMap[fromNum] {
                myPlayers[targetIdx].normalizedX = oldPos.0
                myPlayers[targetIdx].normalizedY = oldPos.1
            }
        }
        playSpikeSound()
    }
    
    // MARK: - Reset
    func resetToDefault() {
        myPlayers = PlayerPosition.defaultMyTeamPositions()
        opponentPlayers = PlayerPosition.defaultOpponentPositions()
        setAttacker(number: 4)
        attackTargetX = 0.35
        attackTargetY = 0.20
        selectedAttackType = .spike4
        tacticsMode = .attack
        activeFormationName = "預設排球陣型"
    }
    
    // MARK: - Save / Load
    func saveCurrentFormation(title: String, note: String = "") {
        let titleToUse = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "戰術陣型 \(savedFormations.count + 1)" : title
        
        let formation = TacticalFormation(
            title: titleToUse,
            note: note,
            dateCreated: Date(),
            myPlayers: myPlayers,
            opponentPlayers: opponentPlayers,
            selectedAttackerNumber: selectedAttackerNumber,
            attackType: selectedAttackType,
            attackTargetX: attackTargetX,
            attackTargetY: attackTargetY
        )
        
        if let existingIdx = savedFormations.firstIndex(where: { $0.title == titleToUse }) {
            savedFormations[existingIdx] = formation
        } else {
            savedFormations.insert(formation, at: 0)
        }
        
        activeFormationName = titleToUse
        persistToUserDefaults()
    }
    
    func applyFormation(_ formation: TacticalFormation) {
        self.myPlayers = formation.myPlayers
        self.opponentPlayers = formation.opponentPlayers
        self.selectedAttackerNumber = formation.selectedAttackerNumber
        self.selectedAttackType = formation.attackType
        self.attackTargetX = formation.attackTargetX
        self.attackTargetY = formation.attackTargetY
        self.activeFormationName = formation.title
        
        if let attackerNum = formation.selectedAttackerNumber {
            setAttacker(number: attackerNum)
        }
    }
    
    func deleteFormation(at offsets: IndexSet) {
        savedFormations.remove(atOffsets: offsets)
        persistToUserDefaults()
    }
    
    func deleteFormation(id: UUID) {
        savedFormations.removeAll(where: { $0.id == id })
        persistToUserDefaults()
    }
    
    private func persistToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(savedFormations)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode saved formations: \(error)")
        }
    }
    
    private func loadSavedFormations() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            savedFormations = try JSONDecoder().decode([TacticalFormation].self, from: data)
        } catch {
            print("Failed to decode saved formations: \(error)")
        }
    }
    
    private func createPresetFormations() {
        let f1 = TacticalFormation(
            title: "經典 4號位強攻陣型",
            note: "標準輪轉，舉球員2號位發動，4號位大斜角強攻",
            myPlayers: PlayerPosition.defaultMyTeamPositions(),
            opponentPlayers: PlayerPosition.defaultOpponentPositions(),
            selectedAttackerNumber: 4,
            attackType: .spike4,
            attackTargetX: 0.25,
            attackTargetY: 0.18
        )
        
        var f2Players = PlayerPosition.defaultMyTeamPositions()
        if let idx = f2Players.firstIndex(where: { $0.number == 3 }) {
            f2Players[idx].normalizedY = 0.53
        }
        let f2 = TacticalFormation(
            title: "快攻 A戰術 (3號位閃電)",
            note: "中路快攻配合，撕裂對方攔網",
            myPlayers: f2Players,
            opponentPlayers: PlayerPosition.defaultOpponentPositions(),
            selectedAttackerNumber: 3,
            attackType: .quickA,
            attackTargetX: 0.50,
            attackTargetY: 0.25
        )
        
        let f3Players = PlayerPosition.defaultMyTeamPositions()
        let f3 = TacticalFormation(
            title: "後排 Pipe 攻擊佈局",
            note: "6號位後排跳攻，前排假快攻掩護",
            myPlayers: f3Players,
            opponentPlayers: PlayerPosition.defaultOpponentPositions(),
            selectedAttackerNumber: 6,
            attackType: .pipe,
            attackTargetX: 0.55,
            attackTargetY: 0.12
        )
        
        savedFormations = [f1, f2, f3]
        persistToUserDefaults()
    }
}
