import SwiftUI
import SwiftData

@main
struct FlowbarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We don't need a WindowGroup since this is a menu bar app
        // The main interface is the status bar item
        Settings {
            EmptyView()
        }
        .modelContainer(DataController.shared.modelContainer)
    }
}
