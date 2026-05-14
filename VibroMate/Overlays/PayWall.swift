import StoreKit
import SwiftUI

struct PayWall: View {
    @EnvironmentObject var iap: IAPManager

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var canShowIntroOffer = false
    @State private var isPurchasing = false
    @State private var purchaseMessage: String?

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let weeklyProduct = iap.products.first { $0.id == Constants.weekly }
            let planDisplay = PaywallPlanDisplay(
                product: weeklyProduct,
                showsIntroOffer: canShowIntroOffer
            )

            ZStack(alignment: .top) {

                Color(hex: "FFF9FD").ignoresSafeArea()
                Image("onb_top")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image("ic_close")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white.opacity(0.75))
                                .frame(width: 28, height: 28)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, width * 0.08)
                    .padding(.top, height * 0.015)

                    Text("Unlimited Access")
                        .font(
                            .custom(
                                "SFProDisplay-Heavy",
                                size: width * 0.06,
                                relativeTo: .title
                            )
                        )
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(.medium ... .xxLarge)
                        .frame(maxWidth: .infinity)
                        .padding(.top, height * 0.015)

                    VStack(spacing: height * 0.025) {
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

                        PlanCard(
                            title: planDisplay.title,
                            subtitle: planDisplay.subtitle,
                            badgeText: planDisplay.badgeText,
                            isSelected: true
                        ) {}
                    }
                    .padding(.horizontal, width * 0.08)
                    .frame(maxHeight: .infinity, alignment: .center)

                    Button(action: {
                        guard let product = weeklyProduct else {
                            purchaseMessage =
                                iap.productLoadError ?? "Subscription is unavailable. Please try again."
                            return
                        }

                        Task {
                            isPurchasing = true
                            purchaseMessage = nil

                            let outcome = await iap.purchase(product: product)
                            isPurchasing = false

                            switch outcome {
                            case .success:
                                dismiss()
                            case .cancelled:
                                break
                            case .pending:
                                purchaseMessage =
                                    "Purchase is pending approval."
                            case .failed(let message):
                                purchaseMessage = message
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(isPurchasing ? "Processing..." : "Continue")
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
                    .disabled(isPurchasing || weeklyProduct == nil)
                    .opacity(isPurchasing || weeklyProduct == nil ? 0.7 : 1.0)

                    if let purchaseMessage {
                        Text(purchaseMessage)
                            .font(.custom("SFProDisplay-Regular", size: 12))
                            .foregroundColor(Color(hex: "#AC57A7"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 8)
                    }

                    VStack(spacing: 20) {

                        HStack(spacing: 8) {
                            Image("ic_shield")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)

                            Text(planDisplay.footerTrustText)
                                .font(.custom("SFProDisplay-Bold", size: 13))
                                .foregroundColor(Color(hex: "#AC57A7"))
                        }

                        HStack(spacing: 40) {
                            Button(action: {
                                openURL(Constants.privacyURL)
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
                                    if iap.isSubscribed {
                                        dismiss()
                                    } else {
                                        purchaseMessage =
                                            "No active subscription was found."
                                    }

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
                                openURL(Constants.termsURL)
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
                .task(id: weeklyProduct?.id) {
                    guard let subscription = weeklyProduct?.subscription else {
                        canShowIntroOffer = false
                        return
                    }

                    canShowIntroOffer = await subscription.isEligibleForIntroOffer
                }

            }
        }

    }
}

struct PlanCard: View {
    let title: String
    let subtitle: String
    let badgeText: String?
    let isSelected: Bool
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

                if let badgeText {
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

private struct PaywallPlanDisplay {
    let title: String
    let subtitle: String
    let badgeText: String?
    let footerTrustText: String

    init(product: Product?, showsIntroOffer: Bool) {
        let billingPeriod = product?.subscription?.subscriptionPeriod.paywallPricePeriodText ?? "week"
        let priceText = product?.displayPrice
        let freeTrialPeriod = product?.freeTrialPeriod(isEligible: showsIntroOffer)

        if let freeTrialPeriod {
            title = "\(freeTrialPeriod.paywallTrialTitlePrefix) Free Trial"
            subtitle = priceText.map { "then \($0) / \(billingPeriod)" } ?? "Loading..."
            badgeText = "\(freeTrialPeriod.paywallTrialBadgePrefix) FREE"
            footerTrustText = "No Payment Now"
        } else {
            title = "Weekly Access"
            subtitle = priceText.map { "\($0) / \(billingPeriod)" } ?? "Loading..."
            badgeText = nil
            footerTrustText = "Cancel Anytime"
        }
    }
}

private extension Product {
    func freeTrialPeriod(isEligible: Bool) -> Product.SubscriptionPeriod? {
        guard
            isEligible,
            let offer = subscription?.introductoryOffer,
            offer.paymentMode == .freeTrial
        else {
            return nil
        }

        return offer.period
    }
}

private extension Product.SubscriptionPeriod {
    var paywallPricePeriodText: String {
        switch unit {
        case .day:
            return value == 1 ? "day" : "\(value) days"
        case .week:
            return value == 1 ? "week" : "\(value) weeks"
        case .month:
            return value == 1 ? "month" : "\(value) months"
        case .year:
            return value == 1 ? "year" : "\(value) years"
        @unknown default:
            return "week"
        }
    }

    var paywallTrialTitlePrefix: String {
        switch unit {
        case .day:
            return value == 1 ? "1-Day" : "\(value)-Day"
        case .week:
            return value == 1 ? "1-Week" : "\(value)-Week"
        case .month:
            return value == 1 ? "1-Month" : "\(value)-Month"
        case .year:
            return value == 1 ? "1-Year" : "\(value)-Year"
        @unknown default:
            return "\(value)-Day"
        }
    }

    var paywallTrialBadgePrefix: String {
        switch unit {
        case .day:
            return value == 1 ? "1 DAY" : "\(value) DAYS"
        case .week:
            return value == 1 ? "1 WEEK" : "\(value) WEEKS"
        case .month:
            return value == 1 ? "1 MONTH" : "\(value) MONTHS"
        case .year:
            return value == 1 ? "1 YEAR" : "\(value) YEARS"
        @unknown default:
            return "\(value) DAYS"
        }
    }
}

#Preview {
    PayWall()
}
