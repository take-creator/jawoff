import SwiftUI

struct RootView: View {
    @Binding var selectedTab: AppTab
    @Binding var isCheckPresented: Bool

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen(selectedTab: $selectedTab, isCheckPresented: $isCheckPresented)
                .tabItem { Label("ホーム", systemImage: "house") }
                .tag(AppTab.home)

            MorningLogScreen()
                .tabItem { Label("朝ログ", systemImage: "sun.max") }
                .tag(AppTab.morning)

            TrendsScreen()
                .tabItem { Label("記録", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(AppTab.charts)

            SettingsScreen()
                .tabItem { Label("設定", systemImage: "bell.badge") }
                .tag(AppTab.settings)

            LearnScreen()
                .tabItem { Label("学習", systemImage: "book") }
                .tag(AppTab.learn)
        }
        .tint(AppDesign.Color.brand)
        .sheet(isPresented: $isCheckPresented) {
            CheckScreen(selectedTab: $selectedTab)
        }
    }
}
