import SwiftUI

struct RootView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen(selectedTab: $selectedTab)
                .tabItem { Label("ホーム", systemImage: "house") }
                .tag(AppTab.home)

            CheckScreen()
                .tabItem { Label("チェック", systemImage: "checkmark.circle") }
                .tag(AppTab.check)

            MorningLogScreen()
                .tabItem { Label("朝ログ", systemImage: "sun.max") }
                .tag(AppTab.morning)

            TrendsScreen()
                .tabItem { Label("推移", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(AppTab.charts)

            SettingsScreen()
                .tabItem { Label("設定", systemImage: "bell.badge") }
                .tag(AppTab.settings)

            LearnScreen()
                .tabItem { Label("学習", systemImage: "book") }
                .tag(AppTab.learn)
        }
        .tint(.teal)
    }
}
