import SwiftUI

struct ContentView: View {
    @StateObject private var store = FormationStore()
    @State private var selectedTab: Int = 0
    
    @State private var showingSaveSheet = false
    @State private var showingLoadSheet = false
    @State private var showingSidebarOnPhone = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: 戰術推演板 (含 攻擊戰術 / 3人接發球 切換模式 & 雙方可拖移)
            TacticalBoardMainPage(
                store: store,
                showingSaveSheet: $showingSaveSheet,
                showingLoadSheet: $showingLoadSheet,
                showingSidebarOnPhone: $showingSidebarOnPhone
            )
            .tabItem {
                Label("戰術推演", systemImage: "sportscourt.fill")
            }
            .tag(0)
            
            // MARK: - Tab 2: 戰術陣型庫 (Formations Library)
            FormationsLibraryView(store: store)
                .tabItem {
                    Label("陣型庫", systemImage: "books.vertical.fill")
                }
                .tag(1)
            
            // MARK: - Tab 3: 球隊隊員名單 (Team Roster - 可修改隊員姓名)
            RosterView(store: store)
                .tabItem {
                    Label("隊員名單", systemImage: "person.3.fill")
                }
                .tag(2)
            
            // MARK: - Tab 4: 統整戰術解析與筆記 (Unified Tactical Explanations & Notes)
            TacticalExplanationView(store: store)
                .tabItem {
                    Label("戰術解析", systemImage: "lightbulb.fill")
                }
                .tag(3)
        }
        .tint(.yellow)
        .sheet(isPresented: $showingSaveSheet) {
            SaveFormationSheet(store: store, isPresented: $showingSaveSheet)
        }
        .sheet(isPresented: $showingLoadSheet) {
            LoadFormationSheet(store: store, isPresented: $showingLoadSheet)
        }
    }
}

// MARK: - Main Tactical Board Page
struct TacticalBoardMainPage: View {
    @ObservedObject var store: FormationStore
    @Binding var showingSaveSheet: Bool
    @Binding var showingLoadSheet: Bool
    @Binding var showingSidebarOnPhone: Bool
    
    var body: some View {
        GeometryReader { outerGeo in
            let isLandscape = outerGeo.size.width > outerGeo.size.height
            let isWideScreen = outerGeo.size.width > 600
            
            ZStack {
                // Background
                Color(red: 0.06, green: 0.09, blue: 0.16)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: Top Navigation Header
                    HStack(spacing: 12) {
                        // Volleyball App Icon / Logo
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .shadow(color: .orange.opacity(0.5), radius: 4)
                            
                            Image(systemName: "volleyball.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("排球戰術板")
                                .customVolleyballTitle(size: 18, weight: .bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 6) {
                                Text("模式:")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(store.tacticsMode.rawValue)
                                    .font(.caption2.bold())
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Spacer()
                        
                        // Mode Quick Selector (模式切換)
                        Picker("", selection: Binding(
                            get: { store.tacticsMode },
                            set: { store.setTacticsMode($0) }
                        )) {
                            Text("攻擊").tag(TacticsMode.attack)
                            Text("3人接發").tag(TacticsMode.serveReceive)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 130)
                        
                        // Sound Toggle Button (扣球音效切換)
                        Button(action: {
                            store.toggleSound()
                        }) {
                            Image(systemName: store.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Circle().fill(store.isSoundEnabled ? Color.purple : Color.gray.opacity(0.4)))
                        }
                        
                        // Toggle Control Panel Button (for compact portrait layout)
                        if !isWideScreen && !isLandscape {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showingSidebarOnPhone.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "slider.horizontal.3")
                                    Text(showingSidebarOnPhone ? "收起" : "設定")
                                }
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.yellow))
                                .foregroundColor(.black)
                            }
                        }
                        
                        // Quick Save Button
                        Button(action: {
                            showingSaveSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Circle().fill(Color.green))
                        }
                        
                        // Quick Load Button
                        Button(action: {
                            showingLoadSheet = true
                        }) {
                            Image(systemName: "folder")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.10, green: 0.14, blue: 0.22))
                    .shadow(radius: 4)
                    
                    // MARK: Main Content Area
                    if isWideScreen || isLandscape {
                        // Wide / Landscape Layout: Left Control Panel + Right Court View
                        HStack(spacing: 0) {
                            AttackControlPanel(
                                store: store,
                                showingSaveSheet: $showingSaveSheet,
                                showingLoadSheet: $showingLoadSheet
                            )
                            .frame(width: 280)
                            .shadow(color: .black.opacity(0.3), radius: 6, x: 3, y: 0)
                            
                            VolleyballCourtView(store: store)
                                .padding(12)
                        }
                    } else {
                        // Compact Portrait Layout: Court View + Collapsible Bottom/Overlay Panel
                        ZStack(alignment: .bottom) {
                            VolleyballCourtView(store: store)
                                .padding(10)
                            
                            if showingSidebarOnPhone {
                                AttackControlPanel(
                                    store: store,
                                    showingSaveSheet: $showingSaveSheet,
                                    showingLoadSheet: $showingLoadSheet
                                )
                                .frame(maxHeight: outerGeo.size.height * 0.55)
                                .cornerRadius(20, corners: [.topLeft, .topRight])
                                .transition(.move(edge: .bottom))
                                .shadow(color: .black.opacity(0.5), radius: 10)
                            }
                        }
                    }
                }
            }
        }
    }
}

// Extension for selective corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ContentView()
}
