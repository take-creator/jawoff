import SwiftUI

@main
struct JawOffApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var notifications = NotificationManager()
    @State private var selectedTab: AppTab = .home

    var body: some Scene {
        WindowGroup {
            RootView(selectedTab: $selectedTab)
                .environmentObject(store)
                .environmentObject(notifications)
                .onReceive(NotificationCenter.default.publisher(for: .jawOffReminderOpened)) { _ in
                    selectedTab = .check
                    store.addReminderLog()
                }
                .onOpenURL { _ in
                    selectedTab = .check
                }
                .task {
                    await notifications.refreshAuthorizationStatus()
                    if store.settings.notificationEnabled {
                        await notifications.scheduleHourlyReminder()
                    }
                }
        }
    }
}

enum AppTab: Hashable {
    case home
    case check
    case morning
    case charts
    case settings
    case learn
}
