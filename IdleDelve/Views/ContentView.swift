import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DungeonView()
                .tabItem { Label("Dungeon", systemImage: "flame.fill") }
            HeroView()
                .tabItem { Label("Hero", systemImage: "person.fill") }
            SkillTreeView()
                .tabItem { Label("Skills", systemImage: "arrow.triangle.branch") }
            PrestigeView()
                .tabItem { Label("Prestige", systemImage: "sparkles") }
        }
    }
}
