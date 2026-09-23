import SwiftUI

struct RosterView: View {
    @ObservedObject var store: FormationStore
    @State private var editingPlayerNumber: Int? = nil
    @State private var tempNameInput: String = ""
    
    // Avatar network photos for volleyball player cards
    let avatarURLs: [Int: String] = [
        1: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80",
        2: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80",
        3: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80",
        4: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80",
        5: "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&q=80",
        6: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Header Banner
                    VStack(alignment: .leading, spacing: 6) {
                        Text("排球隊員 1-6 號位名單 (點擊可修改名字)")
                            .customVolleyballTitle(size: 20, weight: .bold)
                            .foregroundColor(.white)
                        Text("您可以自由點擊「鉛筆按鈕」自訂各號位隊員姓名與角色設定！")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Rotation Rules Detail Box (詳細排球輪轉規則)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("排球標準輪轉規則 (Volleyball Rotation Rules)")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        
                        Text("當全隊獲得換發球權時，所有場上隊員必須依「順時針方向」輪流移位：")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // 輪轉圖解
                        HStack(spacing: 6) {
                            RotationBadge(num: 1, text: "1號位(發球)")
                            Image(systemName: "arrow.right").font(.caption2).foregroundColor(.yellow)
                            RotationBadge(num: 6, text: "6號位(後中)")
                            Image(systemName: "arrow.right").font(.caption2).foregroundColor(.yellow)
                            RotationBadge(num: 5, text: "5號位(後左)")
                            Image(systemName: "arrow.right").font(.caption2).foregroundColor(.yellow)
                            RotationBadge(num: 4, text: "4號位(前左)")
                        }
                        .font(.caption2)
                        
                        HStack(spacing: 6) {
                            Spacer()
                            Image(systemName: "arrow.up").font(.caption2).foregroundColor(.yellow)
                            Spacer()
                            Image(systemName: "arrow.left").font(.caption2).foregroundColor(.yellow)
                            RotationBadge(num: 2, text: "2號位(前右)")
                            Image(systemName: "arrow.left").font(.caption2).foregroundColor(.yellow)
                            RotationBadge(num: 3, text: "3號位(前中)")
                        }
                        .font(.caption2)
                        
                        Text("💡 換發球時，由剛從 2號位(前右) 輪轉至 1號位(後右) 的隊員執行發球。")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue.opacity(0.18)))
                    .padding(.horizontal)
                    
                    // 1 ~ 6 Position Cards with Editable Names
                    VStack(spacing: 12) {
                        ForEach(store.myPlayers) { player in
                            HStack(spacing: 14) {
                                // Avatar Photo (AsyncImage)
                                if let urlString = avatarURLs[player.number], let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        if let img = phase.image {
                                            img.resizable().scaledToFill()
                                        } else {
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(player.role.color, lineWidth: 2))
                                } else {
                                    Circle()
                                        .fill(player.role.color)
                                        .frame(width: 50, height: 50)
                                        .overlay(Text("\(player.number)").bold().foregroundColor(.white))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("\(player.number)號位 - \(player.name)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        // Edit Player Name Button (編輯姓名按鈕)
                                        Button(action: {
                                            tempNameInput = player.name
                                            editingPlayerNumber = player.number
                                        }) {
                                            Image(systemName: "square.and.pencil")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                        }
                                        
                                        if player.isAttacker {
                                            Text("當前攻擊手")
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(Color.yellow))
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Text(player.role.rawValue)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(player.role.color.opacity(0.3)))
                                            .foregroundColor(player.role.color)
                                        
                                        Text(player.number <= 4 && player.number >= 2 ? "前排 (Front)" : "後排 (Back)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    store.setAttacker(number: player.number)
                                }) {
                                    Image(systemName: player.isAttacker ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(player.isAttacker ? .yellow : .gray)
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.16, blue: 0.26)))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.06, green: 0.09, blue: 0.16).ignoresSafeArea())
            .navigationTitle("球隊隊員名單")
            .navigationBarTitleDisplayMode(.inline)
            .alert("修改 \(editingPlayerNumber ?? 1) 號位隊員姓名", isPresented: Binding(
                get: { editingPlayerNumber != nil },
                set: { if !$0 { editingPlayerNumber = nil } }
            )) {
                TextField("輸入新姓名", text: $tempNameInput)
                Button("儲存") {
                    if let num = editingPlayerNumber {
                        store.updatePlayerName(number: num, newName: tempNameInput)
                    }
                    editingPlayerNumber = nil
                }
                Button("取消", role: .cancel) {
                    editingPlayerNumber = nil
                }
            } message: {
                Text("請輸入該號位隊員的名字")
            }
        }
    }
}

struct RotationBadge: View {
    let num: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text("\(num)")
                .font(.caption2.bold())
                .padding(4)
                .background(Circle().fill(Color.yellow))
                .foregroundColor(.black)
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(.white)
        }
    }
}
