import SwiftUI

struct SettingsItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let action: () -> Void
}

struct Settings: View {
    @EnvironmentObject var overlay: OverlayManager
    @EnvironmentObject var iap: IAPManager
    @Environment(\.openURL) private var openURL

    var items: [SettingsItem] {
        var settingsItems = [
            SettingsItem(
                icon: "app_ic_help",
                label: "Get Help",
                action: { openURL(Constants.helpURL) }
            ),
            SettingsItem(
                icon: "app_ic_rate",
                label: "Rate Us",
                action: {
                    if let url = URL(
                        string:
                            "itms-apps://itunes.apple.com/app/id\(Constants.appID)?action=write-review"
                    ) {
                        openURL(url)
                    }
                }
            ),
            SettingsItem(
                icon: "app_ic_terms",
                label: "Terms and Conditions",
                action: { openURL(Constants.termsURL) }
            ),
            SettingsItem(
                icon: "app_ic_privacy",
                label: "Privacy",
                action: { openURL(Constants.privacyURL) }
            )
        ]

        if !iap.isSubscribed {
            settingsItems.append(SettingsItem(
                icon: "app_ic_restore",
                label: "Restore Purchases",
                action: {
                    Task {
                        await iap.restorePurchases()
                    }
                }
            ))
        }

        return settingsItems
    }

    var body: some View {
        ZStack {
            GradientBackgroundView()

            VStack(alignment: .leading, spacing: 30) {
                Text("Settings")
                    .font(.custom("SFProDisplay-Regular", size: 20))
                    .foregroundColor(.white)
                if !iap.isSubscribed {
                    Button(action: {
                        overlay.show()
                    }) {
                        HStack(spacing: 12) {

                            Image("ic_vip")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.yellow)

                            HStack(spacing: 0) {
                                Text("Become ")
                                    .foregroundColor(.white)
                                    .font(
                                        .custom(
                                            "SFProDisplay-Regular",
                                            size: 20
                                        )
                                    )
                                Text("Premium ")
                                    .foregroundColor(.white)
                                    .font(
                                        .custom("SFProDisplay-Bold", size: 20)
                                    )
                                Text("User")
                                    .foregroundColor(.white)
                                    .font(
                                        .custom(
                                            "SFProDisplay-Regular",
                                            size: 20
                                        )
                                    )
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.1),
                                            Color.black.opacity(0.1),
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    }
                }

                VStack(spacing: 10) {
                    ForEach(items) { item in
                        Button(action: item.action) {
                            HStack {
                                Image(item.icon)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(width: 24)

                                Text(item.label)
                                    .foregroundColor(.white)
                                    .font(
                                        .custom(
                                            "SFProDisplay-Regular",
                                            size: 16
                                        )
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .padding(.leading, 5)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }

                            .padding(.vertical, 12)
                            .padding(.horizontal, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.black.opacity(0.15))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                    }
                }
                .padding(.top, 20)

                Spacer()

            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }

    }
}

#Preview {
    Settings()
        .environmentObject(IAPManager.shared)
}
