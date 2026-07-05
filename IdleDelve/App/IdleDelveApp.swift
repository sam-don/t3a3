import SwiftUI

@main
struct IdleDelveApp: App {
    @StateObject private var engine = GameEngine()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
                .onAppear {
                    engine.start()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        engine.start()
                    } else {
                        engine.stop()
                    }
                }
        }
    }
}
