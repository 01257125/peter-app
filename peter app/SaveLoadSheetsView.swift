import SwiftUI

// MARK: - Save Formation Sheet
struct SaveFormationSheet: View {
    @ObservedObject var store: FormationStore
    @Binding var isPresented: Bool
    
    @State private var titleText: String = ""
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("陣型名稱")) {
                    TextField("例如: 輪轉一-4號位強攻", text: $titleText)
                }
                
                Section(header: Text("戰術備註 (選填)")) {
                    TextField("備註說明...", text: $noteText)
                }
                
                Section(header: Text("目前設定摘要")) {
                    HStack {
                        Text("當前攻擊手:")
                        Spacer()
                        Text("\(store.selectedAttackerNumber ?? 1)號位 (\(store.currentAttacker?.role.shortCode ?? ""))")
                            .bold()
                            .foregroundColor(.yellow)
                    }
                    
                    HStack {
                        Text("攻擊戰術:")
                        Spacer()
                        Text(store.selectedAttackType.rawValue)
                            .bold()
                    }
                }
            }
            .navigationTitle("儲存排球戰術陣型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        store.saveCurrentFormation(title: titleText, note: noteText)
                        isPresented = false
                    }
                    .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                titleText = store.activeFormationName
            }
        }
    }
}

// MARK: - Load Saved Formations Sheet
struct LoadFormationSheet: View {
    @ObservedObject var store: FormationStore
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                if store.savedFormations.isEmpty {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("尚無儲存的戰術陣型")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(store.savedFormations) { formation in
                        Button(action: {
                            store.applyFormation(formation)
                            isPresented = false
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(formation.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        if formation.title == store.activeFormationName {
                                            Text("使用中")
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(Color.green))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    if !formation.note.isEmpty {
                                        Text(formation.note)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Label("攻擊: \(formation.selectedAttackerNumber ?? 1)號位", systemImage: "bolt.fill")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                        
                                        Text(formation.attackType.rawValue)
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { offsets in
                        store.deleteFormation(at: offsets)
                    }
                }
            }
            .navigationTitle("已儲存戰術陣型 (\(store.savedFormations.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
