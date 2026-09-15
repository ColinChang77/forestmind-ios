# 森心任務（SwiftUI）

以 SwiftUI 製作的 iPhone 情緒小遊戲。選擇心情後完成 60 秒任務，便會在「我的森林」累積一株心情植物；成果用 `@AppStorage` 存在裝置上。

## 開啟與執行

1. 用 Xcode 開啟 `森心任務.xcodeproj`。
2. 選一台 iPhone Simulator，例如 iPhone 16 Pro。
3. 按 `⌘R` 執行。

## 作業要求對照

| 要求 | 實作位置 |
| --- | --- |
| 小遊戲 | `ContentView.swift` 的心情選擇、60 秒倒數、種植物 |
| 多頁面 | `TabView`：首頁、任務、森林、關於 |
| 專案內圖片 | `Assets.xcassets` 的 ForestFriend 與 AppMark |
| 網路圖片 | 首頁 `AsyncImage` 載入 Unsplash 森林照片 |
| 客製字型 | `Lexend-Regular.ttf`、`Lexend-SemiBold.ttf`，啟動時以 CoreText 註冊 |
| App Icon | `AppIcon.appiconset/AppIcon.png` 是自製的 1024×1024 PNG App Icon |

## 截圖與 GIF

請在 Simulator 裡完成以下畫面後按 `⌘S` 截圖：首頁、選擇心情、任務倒數、任務完成、森林收藏、關於頁。錄製影片可用 Simulator 的 File → Record Screen；再用 macOS「快速動作」或線上轉檔工具將短片轉成 GIF。

可直接貼到 Medium 的文章草稿在 [MEDIUM_POST.md](MEDIUM_POST.md)。
