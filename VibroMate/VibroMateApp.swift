import SwiftUI

@main
struct VibroMateApp: App {

    @StateObject private var overlay = OverlayManager()
    @StateObject private var overlayLock = OverlayLock()

    init() {
        Task { await IAPManager.shared.fetchProducts() }
    }

    var body: some Scene {
        WindowGroup {

            AppRootView()
                .environmentObject(IAPManager.shared)
                .environmentObject(overlay)
                .environmentObject(overlayLock)

        }
    }
}
