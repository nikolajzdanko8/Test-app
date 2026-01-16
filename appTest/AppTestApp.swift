import SwiftUI
import SwiftData

@main
struct AppTestApp: App {
    var body: some Scene {
        WindowGroup {
            MainFlowView()
                .modelContainer(DataManager.shared.modelContainer)
        }
    }
}
