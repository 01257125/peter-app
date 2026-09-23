# 🏐 排球戰術板 (Volleyball Tactics Board)

一款基於 **SwiftUI** 開發的全新 iOS 排球戰術推演與隊伍管理應用程式。專為排球教練、球員與戰術愛好者設計，提供球場 12 人自由拖拽卡位、動態扣球軌跡動畫、3人接發球陣型切換、順時針輪轉、隊員自訂名單與教練戰術筆記功能。

---

## 🌟 核心亮點與功能特色 (Features)

### 🏐 1. 雙模式互動戰術推演板 (Tactical Board)
* **雙模式自由切換**：
  * **`🏐 攻擊戰術推演`**：自由選擇 1~6 號位攻擊手與多種扣球戰術（4號位強攻、A/B快攻、Pipe後排跳攻、背飛、吊球、攔網）。
  * **`🛡️ 3人接發球陣型`**：自動繪製兩位大砲主攻手 (OH1, OH2) 與自由球員 (L) 的半月 W 型接發球弧線，並標示舉球員 (S) 網前插上路線。
* **全場 12 人雙方假人自由拖移**：我方與對手隊員皆可點擊並自由拖拽至球場任意位置。
* **動態球流動與打擊動畫**：具備旋轉飛行的排球、傳球虛線、攻擊軌跡與落點打擊漣漪動畫。
* **順時針輪轉 (Rotation)**：一鍵完成排球標準順時針輪轉（`1號位 ➔ 6號位 ➔ 5號位 ➔ 4號位 ➔ 3號位 ➔ 2號位`）。
* **扣球音效系統**：內建擊球聲響（預設關閉，可於頂部導覽列自由切換）。

### 📚 2. 戰術陣型庫 (Formations Library)
* **經典預設陣型**：內建 4號位強攻、A快攻閃電、 Pipe 後排跳攻等預設佈局。
* **自訂儲存與載入**：隨時將精心設計的站位與戰術儲存，並支援 JSON 序列化持久化保存 (`UserDefaults`)。

### 👥 3. 隊員名單與自訂編輯 (Team Roster)
* **自訂隊員姓名**：點擊 1~6 號位隊員卡片旁的鉛筆圖示，即可自由修改球員名字，全 App 即時同步連動。
* **角色專業分工**：標示舉球員 (S)、主攻手 (OH1/OH2)、副攻/快攻 (MB1/MB2)、舉對 (OP) 與自由球員 (L) 專屬色塊。
* **輪轉規則圖解**：提供清楚的站位順序圖解與邊線防守觀念提示。

### 💡 4. 全方位戰術解析與教練筆記 (Tactical Breakdown & Notes)
* **四大核心體系統整**：詳細圖文說明 4號位強攻、A/B中路快攻、6號位 Pipe 攻擊與 3人接發球站位要領。
* **可修改教練筆記**：教練與球員可自由**新增、編輯與刪除**檢討事項與比賽觀念。

### 🎨 5. 專業視覺與響應式設計 (Design & Layout)
* **標準 3M 三米攻擊線**：依據真實排球場比例精確繪製三米攻擊線與中網。
* **響應式版面**：支援 iPhone (直向/橫向) 與 iPad 寬螢幕佈局。
* **3D 立體排球 App Icon**：專屬高解析度 3D 排球桌面圖示。

---

## 🛠️ 技術架構與使用框架 (Tech Stack)

* **UI 框架**：SwiftUI
* **狀態管理**：Combine (`@StateObject`, `@Published`, `ObservableObject`)
* **資料持久化**：`UserDefaults` + `Codable` JSON Encoder/Decoder
* **音效播放**：`AudioToolbox` (System Sound API)
* **開發環境**：Xcode 15+ / iOS 17.0+ / Swift 5.9+

---

## 📱 專案檔案結構 (Project Structure)

```text
peter app/
├── VolleyballApp.swift            # App @main 程式進入點
├── ContentView.swift              # 4-Tab 導覽與主頁面佈局
├── VolleyballCourtView.swift      # 互動排球場地、球流動動畫與 3人接發球弧線
├── AttackControlPanel.swift       # 攻擊手選擇、戰術模式切換與控制面板
├── Models.swift                   # PlayerPosition, PlayerRole, AttackType 資料模型
├── FormationStore.swift           # 戰術狀態管理、輪轉邏輯與持久化儲存
├── FormationsLibraryView.swift    # 陣型庫檢視與預覽
├── RosterView.swift               # 隊員名單卡片與編輯姓名
├── TacticalExplanationView.swift  # 統整戰術解析與自訂教練筆記
├── CustomFontHelper.swift         # 客製圓潤字體樣式修飾器
├── SaveLoadSheetsView.swift       # 儲存與載入 Modal Sheet
├── peter-app-Info.plist           # App Icon 與顯示名稱配置
└── Assets.xcassets/               # AppIcon 與本地圖片資源
