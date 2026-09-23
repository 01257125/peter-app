import SwiftUI

struct TacticalExplanationView: View {
    @ObservedObject var store: FormationStore
    
    @State private var newNoteText: String = ""
    @State private var showingAddNoteField: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // MARK: 1. Header Banner
                    VStack(alignment: .leading, spacing: 8) {
                        Text("排球全方位戰術解析與觀念指南")
                            .customVolleyballTitle(size: 22, weight: .bold)
                            .foregroundColor(.white)
                        Text("統整「4號位強攻、A/B快攻、 Pipe後排跳攻與 3人接發球」等完整戰術圖文說明。")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // MARK: 2. Unified Tactical Overview Card (寫在一起的統整戰術卡片 - 加大字體)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("戰術體系四大核心 (攻防一體)")
                            .font(.title3.bold())
                            .foregroundColor(.yellow)
                            .padding(.horizontal)
                        
                        UnifiedTacticalCard(
                            sectionNumber: "01",
                            title: "4號位大斜角與直線強攻 (Outside Hitter)",
                            badge: "邊線主攻",
                            color: .orange,
                            items: [
                                "跑位技巧：主攻手由場外三米線外大角度助跑，確保雙腳能在場內最佳打擊點起跳。",
                                "戰術要領：首選大斜角空檔叩擊；若對方雙人攔網封死斜角，則改擊直線邊線或打手出界。"
                            ]
                        )
                        
                        UnifiedTacticalCard(
                            sectionNumber: "02",
                            title: "3號位 A/B 中路快攻 (Middle Blocker)",
                            badge: "時間差閃電",
                            color: .red,
                            items: [
                                "A快攻：快攻手在舉球員身前 0.5 公尺處起跳，舉球員將球急速平推至手中叩擊。",
                                "B快攻：快攻手在身前 1.5~2 公尺處起跳拉開，吸引對手中間攔網手視線，創造掩護。"
                            ]
                        )
                        
                        UnifiedTacticalCard(
                            sectionNumber: "03",
                            title: "6號位後排 Pipe 跳攻 (Back-Row Pipe Attack)",
                            badge: "高空立體攻擊",
                            color: .purple,
                            items: [
                                "立體空間：6號位後排球員由三米線後跳起擊球，落點位於三米線前。",
                                "假動作掩護：前排 3號位作假快攻吸引攔網，舉球員高拋至中路後排完成突襲叩擊。"
                            ]
                        )
                        
                        UnifiedTacticalCard(
                            sectionNumber: "04",
                            title: "3人接發球陣型與走位 (3-Person Serve Receive)",
                            badge: "防守體系",
                            color: .blue,
                            items: [
                                "核心架構：由兩位大砲主攻手 (OH1, OH2) 與自由球員 (L) 形成弧線分工接發球。",
                                "插上舉球：舉球員 (S) 避開接發球區域，發球瞬間快速移至網前 2~3 號位準備流暢舉球。"
                            ]
                        )
                    }
                    
                    // MARK: 3. Customizable Coach Notes (自訂教練筆記 - 加大字體清晰易讀)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "square.and.pencil")
                                .font(.title3)
                                .foregroundColor(.yellow)
                            Text("自訂戰術觀念與教練筆記")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    showingAddNoteField.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("新增筆記")
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal)
                        
                        if showingAddNoteField {
                            HStack {
                                TextField("請輸入新戰術觀念筆記...", text: $newNoteText)
                                    .font(.subheadline)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.black)
                                
                                Button("儲存") {
                                    if !newNoteText.trimmingCharacters(in: .whitespaces).isEmpty {
                                        store.customTacticalNotes.append(newNoteText)
                                        newNoteText = ""
                                        showingAddNoteField = false
                                    }
                                }
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.yellow))
                                .foregroundColor(.black)
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(Array(store.customTacticalNotes.enumerated()), id: \.offset) { index, note in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                        .padding(.top, 2)
                                    
                                    Text(note)
                                        .font(.subheadline.bold()) // 加大筆記字體
                                        .foregroundColor(.white)
                                        .lineSpacing(5)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        store.customTacticalNotes.remove(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.body)
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.16, blue: 0.26)))
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // MARK: 4. Sound Test (扣球擊球音效試聽)
                    HStack {
                        Text("扣球/擊球音效試聽:")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            store.playSpikeSound()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                Text("試聽擊球聲")
                            }
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.orange))
                            .foregroundColor(.white)
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.06, green: 0.09, blue: 0.16).ignoresSafeArea())
            .navigationTitle("戰術解析與筆記")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Unified Tactical Card Component (加大字體)
struct UnifiedTacticalCard: View {
    let sectionNumber: String
    let title: String
    let badge: String
    let color: Color
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(sectionNumber)
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(color))
                
                Text(title)
                    .font(.headline.bold()) // 加大標題字體
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                Text(badge)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(color.opacity(0.3)))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.headline)
                            .foregroundColor(color)
                            .bold()
                        Text(item)
                            .font(.subheadline) // 加大說明字體至 15pt
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.12, green: 0.16, blue: 0.26)))
        .padding(.horizontal)
    }
}
