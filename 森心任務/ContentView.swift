import SwiftUI
import AudioToolbox

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    let emoji: String
    let name: String
    let date: Date
    let mission: String
    let note: String?

    init(id: UUID, emoji: String, name: String, date: Date, mission: String = "給自己一分鐘的停靠。", note: String? = nil) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.date = date
        self.mission = mission
        self.note = note
    }

    private enum CodingKeys: String, CodingKey { case id, emoji, name, date, mission, note }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        emoji = try values.decode(String.self, forKey: .emoji)
        name = try values.decode(String.self, forKey: .name)
        date = try values.decode(Date.self, forKey: .date)
        mission = try values.decodeIfPresent(String.self, forKey: .mission) ?? "給自己一分鐘的停靠。"
        note = try values.decodeIfPresent(String.self, forKey: .note)
    }
}

struct Mood: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    let subtitle: String
    let mission: String
    let plant: String
    let tint: Color
}

private enum SoundEffects {
    static var enabled: Bool { UserDefaults.standard.object(forKey: "soundEffectsEnabled") as? Bool ?? true }
    static func tap() { guard enabled else { return }; AudioServicesPlaySystemSound(1104) }
    static func complete() { guard enabled else { return }; AudioServicesPlaySystemSound(1025) }
}

struct ContentView: View {
    @AppStorage("forestPlants") private var savedPlants = Data()
    @State private var plants: [Plant] = []
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(plants: plants, onStartMission: { selectedTab = 1 })
                .tabItem { Label("此刻", systemImage: "sparkles") }
                .tag(0)
            MissionView(plants: $plants, onOpenForest: { selectedTab = 2 })
                .tabItem { Label("任務", systemImage: "leaf.fill") }
                .tag(1)
            ForestView(plants: plants)
                .tabItem { Label("森林", systemImage: "tree.fill") }
                .tag(2)
            AboutView()
                .tabItem { Label("關於", systemImage: "heart.fill") }
                .tag(3)
        }
        .tint(.forest)
        .onAppear { plants = (try? JSONDecoder().decode([Plant].self, from: savedPlants)) ?? [] }
        .onChange(of: plants) { _, newValue in savedPlants = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}

private struct HomeView: View {
    let plants: [Plant]
    let onStartMission: () -> Void

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        hero
                        HStack(spacing: 14) {
                            StatCard(value: "\(plants.count)", caption: "心情植物", icon: "leaf.fill")
                            StatCard(value: "\(streakDays) 天", caption: completedToday ? "今天已好好停靠" : "今日等待你回來", icon: "flame.fill")
                        }
                        reflection
                    }
                    .frame(width: geometry.size.width - 40)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("森心任務")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var completedToday: Bool {
        plants.contains { Calendar.current.isDateInToday($0.date) }
    }

    private var streakDays: Int {
        let calendar = Calendar.current
        let activeDays = Set(plants.map { calendar.startOfDay(for: $0.date) })
        var cursor = calendar.startOfDay(for: .now)
        if !activeDays.contains(cursor), let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) { cursor = yesterday }
        var count = 0
        while activeDays.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: [Color.forest, Color(red: 0.28, green: 0.51, blue: 0.37)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().fill(.white.opacity(0.08)).frame(width: 190, height: 190).offset(x: 135, y: -100)
            Circle().fill(.white.opacity(0.06)).frame(width: 150, height: 150).offset(x: -150, y: 125)
            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 10) {
                    Image("ForestFriend").resizable().scaledToFit().frame(width: 48, height: 52)
                    Text("森心任務").font(.forest(15, weight: .semibold))
                }
                Text("給心一分鐘，\n讓自己回到自己。")
                    .font(.forest(30, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("選擇此刻的心情，完成一個很小的停靠。")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.86))
                Button(action: onStartMission) {
                    HStack(spacing: 8) {
                        Text("開始今日任務")
                        Image(systemName: "arrow.right")
                    }
                    .font(.forest(14, weight: .semibold))
                    .foregroundStyle(Color.forest)
                    .padding(.horizontal, 15).padding(.vertical, 11)
                    .background(.white, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(maxWidth: .infinity, minHeight: 285)
        .shadow(color: .forest.opacity(0.18), radius: 18, y: 9)
    }

    private var reflection: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "quote.opening")
                .font(.title3.weight(.bold)).foregroundStyle(Color.moss)
            VStack(alignment: .leading, spacing: 7) {
                Text("今天的小提醒").font(.forest(17, weight: .bold))
                Text("你不必馬上變好，只要先溫柔地感覺自己。")
                    .font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(19)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct StatCard: View {
    let value: String
    let caption: String
    let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon).foregroundStyle(Color.moss)
            Text(value).font(.forest(22, weight: .bold))
            Text(caption).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct MissionView: View {
    @Binding var plants: [Plant]
    let onOpenForest: () -> Void
    @State private var selected: Mood?
    @State private var seconds = 60
    @State private var duration = 60
    @State private var running = false
    @State private var completed = false
    @State private var countdownTask: Task<Void, Never>?
    @State private var showReflectionSheet = false
    @State private var reflectionNote = ""

    private let moods = [
        Mood(emoji: "☀️", name: "充滿能量", subtitle: "把這份光留給自己", mission: "閉上眼，想一件讓你期待的小事。", plant: "🌻", tint: .sun),
        Mood(emoji: "🌧️", name: "有點低落", subtitle: "允許自己慢一點", mission: "深呼吸三次，對自己說：我已經很努力了。", plant: "🪻", tint: .lavender),
        Mood(emoji: "🌫️", name: "感到焦慮", subtitle: "先回到此刻", mission: "找出身邊三個看得到的綠色物品。", plant: "🌿", tint: .mistBlue),
        Mood(emoji: "🍃", name: "平靜自在", subtitle: "享受剛好的現在", mission: "聽十秒鐘周圍的聲音，不需要判斷。", plant: "🌱", tint: .softLeaf)
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(completed ? "你為自己留了時間。" : "今天的心情，像哪一種天氣？")
                                .font(.forest(25, weight: .bold))
                            Text(completed ? "這株植物已經種進你的森林。" : "不用想太久，選一個最接近的就好。")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 13) {
                            ForEach(moods) { mood in moodButton(mood) }
                        }
                        if let selected { missionCard(for: selected) }
                    }
                    .frame(width: geometry.size.width - 40, alignment: .leading)
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("今日任務")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showReflectionSheet) {
            if let mood = selected {
                ReflectionSheet(mood: mood, note: $reflectionNote) { savePlant(for: mood) }
            }
        }
    }

    private func moodButton(_ mood: Mood) -> some View {
        Button {
            SoundEffects.tap()
            countdownTask?.cancel()
            selected = mood; seconds = duration; running = false; completed = false; reflectionNote = ""
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack { Text(mood.emoji).font(.system(size: 31)); Spacer(); if selected?.id == mood.id { Image(systemName: "checkmark").font(.caption.bold()).padding(7).background(Color.forest, in: Circle()).foregroundStyle(.white) } }
                Text(mood.name).font(.forest(16, weight: .bold)).foregroundStyle(Color.ink)
                Text(mood.subtitle).font(.caption).foregroundStyle(Color.ink.opacity(0.65)).lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 135, alignment: .leading)
            .padding(16)
            .background(selected?.id == mood.id ? mood.tint.opacity(0.92) : mood.tint.opacity(0.46), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(selected?.id == mood.id ? Color.forest : .clear, lineWidth: 2) }
        }
        .buttonStyle(.plain)
    }

    private func missionCard(for mood: Mood) -> some View {
        VStack(spacing: 17) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("一分鐘任務").font(.forest(18, weight: .bold))
                    Text(mood.mission).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Text(mood.plant).font(.system(size: 37))
            }
            if !running && !completed {
                Stepper(value: $duration, in: 15...300, step: 15) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("設定停靠時間").font(.forest(15, weight: .semibold))
                        Text("\(duration) 秒鐘 · 可從 15 秒到 5 分鐘")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .onChange(of: duration) { _, newValue in seconds = newValue }
                .padding(14)
                .background(Color.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            ZStack {
                Circle().stroke(Color.moss.opacity(0.14), lineWidth: 10)
                Circle().trim(from: 0, to: CGFloat(duration - seconds) / CGFloat(duration)).stroke(Color.moss, style: StrokeStyle(lineWidth: 10, lineCap: .round)).rotationEffect(.degrees(-90)).animation(.easeInOut(duration: 0.3), value: seconds)
                VStack(spacing: 2) { Text("\(seconds)").font(.forest(39, weight: .bold)).monospacedDigit(); Text("秒鐘").font(.caption).foregroundStyle(.secondary) }
            }
            .frame(width: 132, height: 132)
            if completed {
                Button("到我的森林看看") { onOpenForest() }
                    .buttonStyle(ForestButton())
                Button("再做一次") { selected = nil; seconds = duration; completed = false }
                    .font(.forest(15, weight: .semibold)).foregroundStyle(Color.moss)
            } else {
                Button(running ? "暫停倒數" : (seconds == duration ? "開始停靠" : "繼續停靠")) {
                    SoundEffects.tap()
                    running ? pause() : start(mood: mood)
                }
                .buttonStyle(ForestButton())
                Text(running ? "慢慢呼吸，時間正在為你流動。" : "準備好時再開始；你可以隨時暫停。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .forest.opacity(0.08), radius: 16, y: 7)
    }

    private func start(mood: Mood) {
        running = true
        countdownTask = Task {
            while seconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                seconds -= 1
            }
            guard !Task.isCancelled else { return }
            running = false
            showReflectionSheet = true
        }
    }

    private func pause() {
        countdownTask?.cancel()
        countdownTask = nil
        running = false
    }

    private func savePlant(for mood: Mood) {
        let trimmedNote = reflectionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        plants.insert(Plant(id: UUID(), emoji: mood.plant, name: mood.name, date: .now, mission: mood.mission, note: trimmedNote.isEmpty ? nil : trimmedNote), at: 0)
        completed = true
        SoundEffects.complete()
    }
}

private struct ReflectionSheet: View {
    let mood: Mood
    @Binding var note: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("任務完成了 \(mood.plant)").font(.forest(25, weight: .bold))
                Text("想留一句話給此刻的自己嗎？這會和植物一起保存在森林裡。")
                    .foregroundStyle(.secondary)
                TextEditor(text: $note)
                    .font(.forest(16))
                    .frame(minHeight: 130)
                    .padding(10)
                    .background(Color.canvas, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                Button("種下這株植物") { onSave(); dismiss() }
                    .buttonStyle(ForestButton())
                Button("先不寫，直接種下") { note = ""; onSave(); dismiss() }
                    .frame(maxWidth: .infinity).font(.forest(15, weight: .semibold)).foregroundStyle(Color.moss)
                Spacer()
            }
            .padding(24)
            .navigationTitle("留下一句話")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ForestView: View {
    let plants: [Plant]
    @State private var selectedPlant: Plant?
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if plants.isEmpty {
                    VStack(spacing: 15) {
                        Image("ForestFriend").resizable().scaledToFit().frame(width: 145, height: 155)
                        Text("第一株植物，正在等你。 ").font(.forest(22, weight: .bold))
                        Text("完成一個一分鐘任務，讓此刻的心情在森林裡長出形狀。") .font(.subheadline).multilineTextAlignment(.center).foregroundStyle(.secondary).padding(.horizontal, 34)
                    }.padding(.top, 105)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("你的每次停靠，都留下了生長的痕跡。") .font(.subheadline).foregroundStyle(.secondary)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 105), spacing: 13)], spacing: 13) {
                            ForEach(plants) { plant in
                                Button { SoundEffects.tap(); selectedPlant = plant } label: { PlantCard(plant: plant) }
                                    .buttonStyle(.plain)
                            }
                        }.padding(.top, 15)
                    }.padding(20)
                }
            }
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("我的森林")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedPlant) { PlantDetailSheet(plant: $0) }
    }
}

private struct PlantDetailSheet: View {
    let plant: Plant
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(plant.emoji).font(.system(size: 72))
                Text(plant.name).font(.forest(26, weight: .bold))
                Text(plant.date.formatted(.dateTime.year().month(.wide).day())) .font(.subheadline).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 8) {
                    Label("完成的任務", systemImage: "timer") .font(.forest(14, weight: .semibold))
                    Text(plant.mission).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(18).background(Color.canvas, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                if let note = plant.note {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("留給自己的話", systemImage: "quote.opening") .font(.forest(14, weight: .semibold))
                        Text(note).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(18).background(Color.softLeaf.opacity(0.45), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                Spacer()
            }.padding(24).navigationTitle("植物紀錄").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } }
        }
    }
}

private struct PlantCard: View {
    let plant: Plant
    var body: some View {
        VStack(spacing: 8) {
            Text(plant.emoji).font(.system(size: 45))
            Text(plant.name).font(.forest(14, weight: .bold)).foregroundStyle(Color.ink)
            Text(plant.date.formatted(.dateTime.month(.abbreviated).day())) .font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 15)
        .background(.white, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
    }
}

private struct AboutView: View {
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Image("AppMark").resizable().scaledToFit().frame(width: 96)
                        .shadow(color: .forest.opacity(0.18), radius: 12, y: 7)
                    VStack(spacing: 9) {
                        Text("森心任務").font(.forest(29, weight: .bold))
                        Text("把一分鐘還給自己。") .font(.subheadline).foregroundStyle(Color.moss)
                    }
                    Text("不是每個時刻都需要立刻被解決。\n這裡只是邀請你停一下，感覺一下，然後繼續走。")
                        .font(.body).multilineTextAlignment(.center).foregroundStyle(.secondary).lineSpacing(5)
                    Divider().padding(.vertical, 3)
                    VStack(alignment: .leading, spacing: 16) {
                        AboutLine(icon: "heart.fill", title: "感覺", detail: "選擇最靠近現在的心情。")
                        AboutLine(icon: "timer", title: "停靠", detail: "完成一個剛好一分鐘的小任務。")
                        AboutLine(icon: "leaf.fill", title: "生長", detail: "讓每一次回來，長成你的森林。")
                    }
                    Toggle(isOn: $soundEffectsEnabled) {
                        Label("操作音效", systemImage: "speaker.wave.2.fill")
                            .font(.forest(16, weight: .semibold))
                    }
                    .tint(Color.moss)
                    .padding(17)
                    .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(28)
                .frame(maxWidth: .infinity)
            }
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("關於")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct AboutLine: View {
    let icon: String; let title: String; let detail: String
    var body: some View { HStack(spacing: 15) { Image(systemName: icon).frame(width: 22).foregroundStyle(Color.moss); VStack(alignment: .leading, spacing: 3) { Text(title).font(.forest(16, weight: .bold)); Text(detail).font(.subheadline).foregroundStyle(.secondary) } } }
}

private struct ForestButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.frame(maxWidth: .infinity).font(.forest(17, weight: .bold)).padding(16).foregroundStyle(.white).background(Color.forest.opacity(configuration.isPressed ? 0.74 : 1), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
    }
}

private extension Font {
    /// Huninn（粉圓）是為台灣繁中設計的圓體，讓整個 App 保有柔和、陪伴感的語氣。
    static func forest(_ size: CGFloat, weight: Font.Weight = .regular) -> Font { .custom("Huninn-Regular", size: size) }
}

private extension Color {
    static let forest = Color(red: 0.14, green: 0.31, blue: 0.24)
    static let moss = Color(red: 0.30, green: 0.51, blue: 0.35)
    static let canvas = Color(red: 0.94, green: 0.97, blue: 0.92)
    static let ink = Color(red: 0.10, green: 0.16, blue: 0.13)
    static let sun = Color(red: 0.99, green: 0.91, blue: 0.64)
    static let lavender = Color(red: 0.88, green: 0.84, blue: 0.95)
    static let mistBlue = Color(red: 0.82, green: 0.90, blue: 0.92)
    static let softLeaf = Color(red: 0.81, green: 0.91, blue: 0.76)
}

#Preview { ContentView() }
