# 森心任務（SwiftUI）

「森心任務」是一個 iPhone 情緒停靠小工具：選一種當下心情、完成可自訂的短任務，並把這次停下來照顧自己的紀錄，種成森林裡的一株植物。

GitHub 公開專案：[ColinChang77/forestmind-ios](https://github.com/ColinChang77/forestmind-ios)

## 執行方式

1. 用 Xcode 開啟 `森心任務.xcodeproj`。
2. 選擇 iPhone Simulator。
3. 按 `⌘R` 執行。

## 功能

- 四個頁面：此刻、任務、森林、關於。
- 四種心情、15 秒到 5 分鐘的自訂倒數、暫停／續跑。
- 任務完成後留下筆記並種下植物；使用 `@AppStorage` 保存。
- 森林收藏、植物詳情、連續照顧天數與可開關的系統音效。

## 作業要求對照

| 要求 | 成品證據 |
| --- | --- |
| 小遊戲／工具 App | 心情任務、可自訂倒數、完成後種植物。 |
| 多個頁面 | `TabView` 的此刻、任務、森林、關於。 |
| AI 輔助 IDE 開發 | 使用 Codex 與 Xcode 完成 SwiftUI 專案。 |
| App 名稱與 Icon | App 名稱「森心任務」；`AppIcon.appiconset/AppIcon.png`。 |
| 本機圖片 | `Assets.xcassets` 的 `ForestFriend`、`AppMark` SVG。 |
| 網路圖片 | 關於頁以 `AsyncImage` 顯示 Unsplash 森林照片。 |
| 客製字體 | `Huninn-Regular.ttf`（粉圓）已打包並透過 CoreText 註冊。 |
| AI 對話 | `/Users/holingchang/Desktop/conversation.txt`。 |
| App 畫面截圖 | `SCREENSHOTS/01-home.png` 至 `SCREENSHOTS/05-about.png`。 |
| 最終操作影片 | `SCREENSHOTS/森心任務-demo-1min.mp4`（62.928 秒）。 |
| 加分音效 | 關於頁可切換操作與完成音效。 |

## 素材與授權

- 網路照片：[Unsplash forest photo](https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=900&q=80)
- 本機插圖與 App Icon：自行製作 SVG／PNG。
- 字體：Huninn（粉圓），OFL 授權檔為 `森心任務/OFL-Huninn.txt`。

Medium 作業草稿在 [MEDIUM_POST.md](MEDIUM_POST.md)。
