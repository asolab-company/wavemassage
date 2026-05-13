import SwiftUI

enum PlanType {
    case weekly, yearly
}

struct PayWall: View {
    @EnvironmentObject var iap: IAPManager

    @State private var currentTab = 0

    @State private var selectedPlan: PlanType = .weekly
    @State private var isTrialEnabled: Bool = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack(alignment: .top) {

                Color(hex: "FFF9FD").ignoresSafeArea()
                Image("paywall_top")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()

                Text("Unlimited Access")
                    .font(
                        .custom(
                            "SFProDisplay-Heavy",
                            size: width * 0.06,
                            relativeTo: .title
                        )
                    )
                    .foregroundColor(Color(hex: "AC57A7"))
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.medium ... .xxLarge)
                    .frame(maxWidth: .infinity)
                    .padding(.top, height * 0.05)

                VStack {
                    VStack(spacing: height * 0.015) {

                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image("ic_close")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                            }

                            Spacer()
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: height * 0.02) {
                            InfoRow(
                                icon: "ic_check",
                                iconColor: Color(hex: "#A75AAC"),
                                title: "Unlock all vibration modes",
                                description:
                                    "Experience over 20 unique massage modes"
                            )

                            InfoRow(
                                icon: "ic_check",
                                iconColor: Color(hex: "#A75AAC"),
                                title: "Unlock all vibration intensity levels",
                                description:
                                    "Customize the intensity to your preference"
                            )

                            InfoRow(
                                icon: "ic_check",
                                iconColor: Color(hex: "#A75AAC"),
                                title: "Unlock all vibration speeds",
                                description:
                                    "Control the pace from gentle to intense"
                            )
                        }
                        .padding(.horizontal, width * 0.05)
                        .padding(.vertical, width * 0.03)
                        .padding(.bottom, height * 0.015)
                        .background(Color(hex: "#AC57A7").opacity(0.1))
                        .cornerRadius(24)
                        .frame(maxWidth: .infinity)

                        HStack {
                            Text("Free Trial Enabled")
                                .foregroundColor(
                                    selectedPlan == .weekly
                                        ? .black : Color.init(hex: "AC57A7")
                                )
                                .font(.custom("SFProDisplay-Medium", size: 15))
                                .dynamicTypeSize(.medium ... .xxLarge)

                            Spacer()

                            Toggle("", isOn: $isTrialEnabled)
                                .labelsHidden()
                                .tint(Color(hex: "#419400"))
                                .onChange(of: isTrialEnabled) { newValue in
                                    if newValue {
                                        selectedPlan = .weekly
                                    } else {
                                        selectedPlan = .yearly
                                    }
                                }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#A75AAC"),
                                            Color(hex: "#D0437D"),
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ).opacity(0.22)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "#A75AAC"),
                                                    Color(hex: "#D0437D"),
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )

                        PlanCard(
                            title: "3–Days Free Trial",
                            subtitle: "then $9.99 / week",
                            badgeText: "3 DAYS FREE",
                            isSelected: selectedPlan == .weekly,

                            planType: .weekly
                        ) {
                            selectedPlan = .weekly
                            isTrialEnabled = true
                        }

                        PlanCard(
                            title: "Yearly Access",
                            subtitle: "$44.99 / year",
                            badgeText: "BEST OFFER",
                            isSelected: selectedPlan == .yearly,

                            planType: .yearly
                        ) {
                            selectedPlan = .yearly
                            isTrialEnabled = false
                        }

                    }
                    .padding(.horizontal, width * 0.08)
                    .padding(.bottom, height * 0.015)

                    Button(action: {
                        guard
                            let product = iap.products.first(where: {
                                $0.id
                                    == (selectedPlan == .weekly
                                        ? Constants.weekly : Constants.yearly)
                            })
                        else {
                            return
                        }

                        Task {
                            do {
                                try await iap.purchase(product: product)
                                dismiss()
                            } catch {
                                print(
                                    "Ошибка покупки:",
                                    error.localizedDescription
                                )
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .foregroundColor(.white)
                                .font(.custom("SFProDisplay-Bold", size: 18))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(hex: "#AC57A7"))
                        .cornerRadius(40)
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)

                    VStack(spacing: 20) {

                        HStack(spacing: 8) {
                            Image("ic_shield")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)

                            Text(
                                isTrialEnabled
                                    ? "No Payment Now" : "Cancel Anytime"
                            )
                            .font(.custom("SFProDisplay-Bold", size: 13))
                            .foregroundColor(Color(hex: "#AC57A7"))
                        }

                        HStack(spacing: 40) {
                            Button(action: {
                                UIApplication.shared.open(Constants.privacyURL)
                            }) {
                                Text("Privacy Policy")
                                    .font(
                                        .custom(
                                            "SFProDisplay-Regular",
                                            size: 14
                                        )
                                    )
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                            }

                            Button(action: {
                                Task {
                                    await iap.restorePurchases()

                                }
                            }) {
                                Text("Restore")
                                    .font(
                                        .custom(
                                            "SFProDisplay-Regular",
                                            size: 14
                                        )
                                    )
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                            }

                            Button(action: {
                                UIApplication.shared.open(Constants.termsURL)
                            }) {
                                Text("Terms of Use")
                                    .font(
                                        .custom(
                                            "SFProDisplay-Regular",
                                            size: 14
                                        )
                                    )
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }

            }
        }

    }
}

struct PlanCard: View {
    let title: String
    let subtitle: String
    let badgeText: String
    let isSelected: Bool
    let planType: PlanType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom("SFProDisplay-Medium", size: 15))
                        .foregroundColor(.black)

                    Text(subtitle)
                        .font(.custom("SFProDisplay-Regular", size: 12))
                        .foregroundColor(.black)
                }

                Spacer()

                if planType == .weekly {
                    Text(badgeText)
                        .font(.custom("SFProDisplay-Medium", size: 11))
                        .fontWeight(.bold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.white)
                        )
                        .foregroundColor(Color.init(hex: "D0437D"))
                } else {

                    Text(badgeText)
                        .font(.custom("SFProDisplay-Medium", size: 11))
                        .fontWeight(.bold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#A75AAC"),
                                            Color(hex: "#D0437D"),
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)

                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#A75AAC"), Color(hex: "#D0437D"),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ).opacity(0.22)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#A75AAC"),
                                        Color(hex: "#D0437D"),
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: isSelected ? 3.5 : 1.5
                            )
                    )
            )
        }
    }
}

#Preview {
    PayWall()
}
