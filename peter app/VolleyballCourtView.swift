import SwiftUI

struct VolleyballCourtView: View {
    @ObservedObject var store: FormationStore
    @State private var draggingPlayerId: UUID? = nil
    @State private var isDraggingTarget: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            
            ZStack {
                // MARK: 1. Court Flooring Background (包含標準比例三米線)
                CourtBackgroundView()
                
                // MARK: 2. Volleyball Net (中間網子)
                VolleyballNetView(width: w, centerY: h * 0.5)
                
                // MARK: 3. Serve Receive Mode Visual Overlay (3人接發球弧線與舉球員插上箭頭)
                if store.tacticsMode == .serveReceive {
                    ServeReceiveOverlayView(myPlayers: store.myPlayers, width: w, height: h)
                }
                
                // MARK: 4. Attack Vector & Ball Flow Animation (扣球流動與軌跡 - 在攻擊模式下顯示)
                if store.tacticsMode == .attack, let attacker = store.currentAttacker {
                    let attackerPos = CGPoint(
                        x: attacker.normalizedX * w,
                        y: attacker.normalizedY * h
                    )
                    let targetPos = CGPoint(
                        x: store.attackTargetX * w,
                        y: store.attackTargetY * h
                    )
                    
                    // Find Setter position if available for ball pass animation
                    let setterPlayer = store.myPlayers.first(where: { $0.role == .setter })
                    let setterPos = setterPlayer != nil ? CGPoint(x: setterPlayer!.normalizedX * w, y: setterPlayer!.normalizedY * h) : nil
                    
                    AttackVectorOverlay(
                        startPoint: attackerPos,
                        endPoint: targetPos,
                        attackType: store.selectedAttackType,
                        setterPoint: setterPos,
                        attackerNumber: attacker.number
                    )
                    
                    // Draggable Target Pin (攻擊落點標籤與漣漪動畫)
                    AttackTargetPinView(
                        position: targetPos,
                        attackType: store.selectedAttackType
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingTarget = true
                                let normX = min(max(value.location.x / w, 0.05), 0.95)
                                let normY = min(max(value.location.y / h, 0.04), 0.49) // Opponent court side
                                store.attackTargetX = normX
                                store.attackTargetY = normY
                            }
                            .onEnded { _ in
                                isDraggingTarget = false
                            }
                    )
                }
                
                // MARK: 5. Opponent Players (對手假人 1-6 號位 - 可自由拖移)
                ForEach(store.opponentPlayers) { player in
                    let pos = CGPoint(
                        x: player.normalizedX * w,
                        y: player.normalizedY * h
                    )
                    PlayerDummyNodeView(
                        player: player,
                        isDragging: draggingPlayerId == player.id
                    )
                    .position(pos)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                draggingPlayerId = player.id
                                let normX = value.location.x / w
                                let normY = value.location.y / h
                                store.updatePlayerPosition(id: player.id, newX: normX, newY: normY, isMyTeam: false)
                            }
                            .onEnded { _ in
                                draggingPlayerId = nil
                            }
                    )
                }
                
                // MARK: 6. My Team Players (我方假人 1-6 號位 - 可自由拖移)
                ForEach(store.myPlayers) { player in
                    let pos = CGPoint(
                        x: player.normalizedX * w,
                        y: player.normalizedY * h
                    )
                    PlayerDummyNodeView(
                        player: player,
                        isDragging: draggingPlayerId == player.id
                    )
                    .position(pos)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                draggingPlayerId = player.id
                                let normX = value.location.x / w
                                let normY = value.location.y / h
                                store.updatePlayerPosition(id: player.id, newX: normX, newY: normY, isMyTeam: true)
                            }
                            .onEnded { _ in
                                draggingPlayerId = nil
                            }
                    )
                    .onTapGesture {
                        store.setAttacker(number: player.number)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - 3-Person Serve Receive Overlay Arc Graphic (3人接發球弧線與指示線)
struct ServeReceiveOverlayView: View {
    let myPlayers: [PlayerPosition]
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let oh1 = myPlayers.first(where: { $0.role == .outside1 })
        let libero = myPlayers.first(where: { $0.role == .libero })
        let oh2 = myPlayers.first(where: { $0.role == .outside2 })
        let setter = myPlayers.first(where: { $0.role == .setter })
        
        ZStack {
            // 3-Person Reception Curve Line (兩大砲 + 自由球員接發球弧線)
            if let p1 = oh1, let p2 = libero, let p3 = oh2 {
                let pt1 = CGPoint(x: p1.normalizedX * width, y: p1.normalizedY * height)
                let pt2 = CGPoint(x: p2.normalizedX * width, y: p2.normalizedY * height)
                let pt3 = CGPoint(x: p3.normalizedX * width, y: p3.normalizedY * height)
                
                Path { path in
                    path.move(to: pt1)
                    path.addLine(to: pt2)
                    path.addLine(to: pt3)
                }
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 4]))
                .shadow(color: .yellow.opacity(0.8), radius: 4)
                
                // Receive zone label
                Text("3人接發球區域 (OH1 - L - OH2)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.yellow))
                    .position(x: pt2.x, y: pt2.y + 24)
            }
            
            // Setter Insertion Arrow (舉球員網前插上箭頭)
            if let s = setter {
                let sPt = CGPoint(x: s.normalizedX * width, y: s.normalizedY * height)
                let targetPt = CGPoint(x: width * 0.70, y: height * 0.54) // Net 2/3 position
                
                if hypot(sPt.x - targetPt.x, sPt.y - targetPt.y) > 15 {
                    Path { path in
                        path.move(to: sPt)
                        path.addLine(to: targetPt)
                    }
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.purple)
                        .position(targetPt)
                }
            }
        }
    }
}

// MARK: - Court Background Graphics (三米線正確位置: 距離網子 3m = 全場的 1/6 距離)
struct CourtBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let margin: CGFloat = 16
            
            let courtTop = margin
            let courtBottom = h - margin
            let courtHeight = courtBottom - courtTop
            let centerY = courtTop + courtHeight * 0.5
            
            let threeMeterOffset = courtHeight * (3.0 / 18.0)
            let y3mTop = centerY - threeMeterOffset     // 對手三米線
            let y3mBottom = centerY + threeMeterOffset  // 我方三米線
            
            ZStack {
                // Free zone area (Deep Blue)
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.15, blue: 0.32), Color(red: 0.05, green: 0.10, blue: 0.22)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Active Volleyball Playing Court (Volleyball Orange)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.93, green: 0.55, blue: 0.22), Color(red: 0.88, green: 0.48, blue: 0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(margin)
                    .shadow(color: .black.opacity(0.4), radius: 6)
                
                // Boundary Lines (外框白線)
                Rectangle()
                    .stroke(Color.white, lineWidth: 4)
                    .padding(margin)
                
                // 三米攻擊線 (3-Meter Attack Lines)
                Path { path in
                    path.move(to: CGPoint(x: margin, y: y3mTop))
                    path.addLine(to: CGPoint(x: w - margin, y: y3mTop))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, dash: [8, 4]))
                
                Path { path in
                    path.move(to: CGPoint(x: margin, y: y3mBottom))
                    path.addLine(to: CGPoint(x: w - margin, y: y3mBottom))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, dash: [8, 4]))
                
                // 三米線標籤
                Group {
                    Text("3M 三米線")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 4)
                        .background(Capsule().fill(Color.black.opacity(0.4)))
                        .position(x: margin + 35, y: y3mTop - 8)
                    
                    Text("3M 三米線")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 4)
                        .background(Capsule().fill(Color.black.opacity(0.4)))
                        .position(x: margin + 35, y: y3mBottom + 8)
                }
                
                // Court Labels
                VStack {
                    Text("對手場地 (OPPONENT)")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, margin + 6)
                    
                    Spacer()
                    
                    Text("我方場地 (MY TEAM)")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, margin + 6)
                }
            }
        }
    }
}

// MARK: - Center Volleyball Net Graphic
struct VolleyballNetView: View {
    let width: CGFloat
    let centerY: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(width: width, height: 12)
                .position(x: width * 0.5, y: centerY + 4)
            
            Rectangle()
                .fill(
                    ImagePaint(
                        image: Image(systemName: "square.grid.3x3.fill"),
                        scale: 0.1
                    )
                )
                .background(Color.white.opacity(0.2))
                .frame(width: width - 8, height: 16)
                .position(x: width * 0.5, y: centerY)
            
            Rectangle()
                .fill(Color.white)
                .frame(width: width - 8, height: 5)
                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                .position(x: width * 0.5, y: centerY - 6)
            
            VStack(spacing: 0) {
                Rectangle().fill(Color.red).frame(width: 4, height: 6)
                Rectangle().fill(Color.white).frame(width: 4, height: 6)
                Rectangle().fill(Color.red).frame(width: 4, height: 6)
                Rectangle().fill(Color.white).frame(width: 4, height: 6)
            }
            .position(x: 20, y: centerY - 4)
            
            VStack(spacing: 0) {
                Rectangle().fill(Color.red).frame(width: 4, height: 6)
                Rectangle().fill(Color.white).frame(width: 4, height: 6)
                Rectangle().fill(Color.red).frame(width: 4, height: 6)
                Rectangle().fill(Color.white).frame(width: 4, height: 6)
            }
            .position(x: width - 20, y: centerY - 4)
            
            Text("NET 網子")
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.white))
                .position(x: width * 0.5, y: centerY)
        }
    }
}

// MARK: - Player Dummy Node View
struct PlayerDummyNodeView: View {
    let player: PlayerPosition
    let isDragging: Bool
    
    var isMyTeam: Bool { player.team == .myTeam }
    
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if player.isAttacker {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 4)
                        .frame(width: 52, height: 52)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                        .shadow(color: .yellow, radius: isPulsing ? 10 : 4)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                isPulsing = true
                            }
                        }
                }
                
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .offset(y: 3)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isMyTeam
                            ? [player.role.color, player.role.color.opacity(0.8)]
                            : [Color.gray, Color.black.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(player.isAttacker ? Color.yellow : Color.white, lineWidth: 2)
                    )
                
                VStack(spacing: 0) {
                    Text("\(player.number)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(player.role.shortCode)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                if player.isAttacker {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                        .offset(x: 18, y: -18)
                }
            }
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isDragging)
            
            Text("\(player.number)號位 \(player.name)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(isMyTeam ? Color.black.opacity(0.7) : Color.red.opacity(0.7))
                )
                .shadow(radius: 2)
        }
    }
}

// MARK: - Attack Vector Overlay & Dynamic Ball Flow Animation
struct AttackVectorOverlay: View {
    let startPoint: CGPoint
    let endPoint: CGPoint
    let attackType: AttackType
    let setterPoint: CGPoint?
    let attackerNumber: Int
    
    @State private var animProgress: CGFloat = 0.0
    @State private var dashPhase: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            if let setterPos = setterPoint, hypot(setterPos.x - startPoint.x, setterPos.y - startPoint.y) > 15 {
                Path { path in
                    path.move(to: setterPos)
                    path.addLine(to: startPoint)
                }
                .stroke(
                    Color.purple.opacity(0.8),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 4], dashPhase: -dashPhase)
                )
            }
            
            Path { path in
                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            .stroke(
                LinearGradient(
                    colors: [.yellow, .orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10, 6], dashPhase: -dashPhase)
            )
            .shadow(color: .orange.opacity(0.8), radius: 6)
            
            let currentBallX = startPoint.x + (endPoint.x - startPoint.x) * animProgress
            let currentBallY = startPoint.y + (endPoint.y - startPoint.y) * animProgress
            let currentBallPos = CGPoint(x: currentBallX, y: currentBallY)
            
            Circle()
                .fill(Color.orange.opacity(0.5))
                .frame(width: 24, height: 24)
                .position(currentBallPos)
                .blur(radius: 4)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .yellow, radius: 4)
                
                Image(systemName: "volleyball.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(Double(animProgress * 720)))
            }
            .position(currentBallPos)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: startPoint) { _, _ in
            startAnimations()
        }
        .onChange(of: endPoint) { _, _ in
            startAnimations()
        }
    }
    
    private func startAnimations() {
        animProgress = 0.0
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
            animProgress = 1.0
        }
        withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
            dashPhase = 32.0
        }
    }
}

// MARK: - Attack Target Pin View with Impact Ripple
struct AttackTargetPinView: View {
    let position: CGPoint
    let attackType: AttackType
    
    @State private var rippleScale: CGFloat = 0.8
    @State private var rippleOpacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(rippleOpacity), lineWidth: 3)
                    .frame(width: 36, height: 36)
                    .scaleEffect(rippleScale)
                
                Circle()
                    .stroke(Color.yellow.opacity(rippleOpacity), lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .scaleEffect(rippleScale * 1.2)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 28, height: 28)
                    .shadow(color: .red, radius: 6)
                
                Image(systemName: attackType.iconName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("攻擊落點 (拖曳)")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.yellow)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Capsule().fill(Color.black.opacity(0.8)))
        }
        .position(position)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                rippleScale = 1.8
                rippleOpacity = 0.0
            }
        }
    }
}
