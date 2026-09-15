import SwiftUI
import CoreText

@main
struct ForestMindApp: App {
    init() {
        for font in ["Lexend-Regular", "Lexend-SemiBold"] {
            if let url = Bundle.main.url(forResource: font, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
