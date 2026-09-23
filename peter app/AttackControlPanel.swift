import SwiftUI

struct AttackControlPanel: View {
    @ObservedObject var store: FormationStore
    @Binding var showingSaveSheet: Bool
    @Binding var showingLoadSheet: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            
            // MARK: 1. Mode Switcher (戰術模式切換: 攻擊戰術 / 3人接發球)
            VStack(spacing: 6) {
                Text("戰術模式選擇")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                Picker("戰術模式", selection: Binding(
                    get: { store.tacticsMode },
                    set: { store.setTacticsMode($0) }
                )) {
                    ForEach(TacticsMode.allCases) { mode in
                        HStack {
                            Image(systemName: mode.iconName)
                            Text(mode.rawValue)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: Mode 1: 攻擊戰術設定 (Attack Mode)
                    if store.tacticsMode == .attack {
                        // Section 1: Attacker Selection (1-6號位)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "person.badge.shield.checkmark.fill")
                                    .foregroundColor(.yellow)
                                Text("選擇主要攻擊手 (點擊號位)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(store.myPlayers) { player in
                                    Button(action: {
                                        store.setAttacker(number: player.number)
                                    }) {
                                        VStack(spacing: 2) {
                                            HStack(spacing: 2) {
                                                Text("\(player.number)號位")
                                                    .font(.caption.bold())
                                                if player.isAttacker {
                                                    Image(systemName: "bolt.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                            Text(player.role.shortCode)
                                                .font(.system(size: 9, weight: .heavy))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(player.isAttacker ? Color.yellow : Color(red: 0.16, green: 0.22, blue: 0.34))
                                        )
                                        .foregroundColor(player.isAttacker ? .black : .white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(player.role.color, lineWidth: player.isAttacker ? 3 : 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.10, green: 0.14, blue: 0.22)))
                        
                        // Section 2: Attack Type Selection
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "bolt.horizontal.circle.fill")
                                    .foregroundColor(.orange)
                                Text("攻擊戰術類型 (Attack Pattern)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 6) {
                                ForEach(AttackType.allCases) { type in
                                    Button(action: {
                                        store.selectedAttackType = type
                                    }) {
                                        HStack {
                                            Image(systemName: type.iconName)
                                                .foregroundColor(store.selectedAttackType == type ? .black : .orange)
                                            Text(type.rawValue)
                                                .font(.caption.bold())
                                            Spacer()
                                            if store.selectedAttackType == type {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(store.selectedAttackType == type ? Color.orange : Color(red: 0.16, green: 0.22, blue: 0.34))
                                        )
                                        .foregroundColor(store.selectedAttackType == type ? .black : .white)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.10, green: 0.14, blue: 0.22)))
                    }
                    
                    // MARK: Mode 2: 3人接發球設定 (Serve Receive Mode)
                    else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "shield.inset.filled")
                                    .foregroundColor(.yellow)
                                Text("3人接發球陣型與輪轉")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Text("後場由兩位大砲主攻手 (OH1, OH2) 與自由球員 (L) 形成 3 人半月弧線，舉球員 (S) 前插網前。場上所有隊員皆可自由拖移！")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineSpacing(3)
                            
                            Button(action: {
                                store.apply3PersonReceiveFormation()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("重設 3人接發球 W弧線站位")
                                }
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.yellow))
                                .foregroundColor(.black)
                            }
                            
                            // Receivers Legend
                            VStack(alignment: .leading, spacing: 6) {
                                Text("接發球三大分工角色:")
                                    .font(.caption2.bold())
                                    .foregroundColor(.yellow)
                                
                                HStack(spacing: 8) {
                                    RoleBadge(code: "OH1", name: "大砲(左)", color: .orange)
                                    RoleBadge(code: "L", name: "自由(中)", color: .yellow)
                                    RoleBadge(code: "OH2", name: "大砲(右)", color: .orange)
                                }
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.10, green: 0.14, blue: 0.22)))
                    }
                    
                    // MARK: Section 3: Rotation & Presets Controls (通用於雙模式)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("全隊輪轉與重置操作")
                            .font(.caption.bold())
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 10) {
                            // 順時針輪轉按鈕 (Rotate Clockwise 1->6->5->4->3->2)
                            Button(action: {
                                store.rotateMyTeamClockwise()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("順時針輪轉")
                                }
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                                .foregroundColor(.white)
                            }
                            
                            // 重置陣型按鈕
                            Button(action: {
                                store.resetToDefault()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("重置預設")
                                }
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.4)))
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.10, green: 0.14, blue: 0.22)))
                    
                    // MARK: Section 4: Quick Save & Load
                    HStack(spacing: 10) {
                        Button(action: {
                            showingSaveSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("儲存戰術")
                            }
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                            .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            showingLoadSheet = true
                        }) {
                            HStack {
                                Image(systemName: "folder")
                                Text("載入陣型")
                            }
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.cyan))
                            .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
        .background(Color(red: 0.08, green: 0.11, blue: 0.18).ignoresSafeArea())
    }
}

struct RoleBadge: View {
    let code: String
    let name: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(code)
                .font(.system(size: 9, weight: .bold))
                .padding(3)
                .background(Circle().fill(color))
                .foregroundColor(color == .yellow ? .black : .white)
            Text(name)
                .font(.system(size: 9))
                .foregroundColor(.white)
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.06)))
    }
}
