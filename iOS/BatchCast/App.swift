import SwiftUI

@main
struct BatchCastApp: App {
    @StateObject private var store = BatchCastStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchcast_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BCHaptics.enabled = hapticsEnabled
                }
        }
    }
}
