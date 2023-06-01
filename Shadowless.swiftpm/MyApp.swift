import SwiftUI

@main
struct ShadowlessLampApp: App {
    @Environment(\.scenePhase) private var scenePhase
    func onAppear() {
        print("App appeared.")
    }
    
    //  func onDidBecomeActive() {
    //    print("App UI appeared")
    //  }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("[App]: App becomes active.")
            case .inactive:
                print("[App]: App becomes inactive.")
            case .background:
                print("[App]: App enters background.")
            @unknown default:
                print("[App]: Unknown App status.")
            }
        }
    }
}
