import SwiftUI

struct FormationsLibraryView: View {
    @ObservedObject var store: FormationStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: 1. Local Assets Banner (專案 Banner 圖片)
                    ZStack(alignment: .bottomLeading) {
                        Image("VolleyballBanner")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.8)],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("排球戰術陣型庫")
                                .customVolleyballTitle(size: 22, weight: .black)
                                .foregroundColor(.white)
                            Text("內含 \(store.savedFormations.count) 個戰術陣型與自訂佈局")
                                .font(.caption.bold())
                                .foregroundColor(.yellow)
                        }
                        .padding(16)
                    }
                    .padding(.horizontal)
                    
                    // MARK: 2. Spike Action Photo Card
                    HStack(spacing: 14) {
                        Image("SpikeAction")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(radius: 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("扣球時機與戰術發動")
                                .customVolleyballTitle(size: 16, weight: .bold)
                                .foregroundColor(.white)
                            Text("算準舉球時間差與擊球高點，搭配發球掩護發揮團隊最大戰力。")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(3)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                    .padding(.horizontal)
                    
                    // MARK: 3. Saved Formations List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("已儲存戰術陣型 (\(store.savedFormations.count))")
                            .font(.headline.bold())
                            .foregroundColor(.yellow)
                            .padding(.horizontal)
                        
                        ForEach(store.savedFormations) { formation in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formation.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        if !formation.note.isEmpty {
                                            Text(formation.note)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    
                                    Button(action: {
                                        store.applyFormation(formation)
                                    }) {
                                        Text("載入陣型")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(Color.yellow))
                                            .foregroundColor(.black)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Label("主攻: \(formation.selectedAttackerNumber ?? 1)號位", systemImage: "bolt.fill")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                    
                                    Text("戰術: \(formation.attackType.rawValue)")
                                        .font(.caption2)
                                        .foregroundColor(.cyan)
                                }
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.16, blue: 0.26)))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.06, green: 0.09, blue: 0.16).ignoresSafeArea())
            .navigationTitle("戰術陣型庫")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
