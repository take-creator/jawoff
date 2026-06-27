import SwiftUI

@main
struct JawOffApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var notifications = NotificationManager()
    @State private var selectedTab: AppTab = .home
    @State private var isCheckPresented = false

    var body: some Scene {
        WindowGroup {
            RootView(selectedTab: $selectedTab, isCheckPresented: $isCheckPresented)
                .environmentObject(store)
                .environmentObject(notifications)
                .onReceive(NotificationCenter.default.publisher(for: .jawOffReminderOpened)) { _ in
                    selectedTab = .home
                    isCheckPresented = true
                    store.addReminderLog()
                    if store.settings.notificationEnabled, store.settings.reminderFrequency == .random25to55 {
                        Task {
                            await notifications.scheduleReminder(frequency: store.settings.reminderFrequency)
                        }
                    }
                }
                .onOpenURL { _ in
                    selectedTab = .home
                    isCheckPresented = true
                }
                .task {
                    await notifications.refreshAuthorizationStatus()
                    if store.settings.notificationEnabled {
                        await notifications.scheduleReminder(frequency: store.settings.reminderFrequency)
                    }
                }
        }
    }
}

enum AppTab: Hashable {
    case home
    case morning
    case charts
    case settings
    case learn
}
