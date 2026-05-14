import SwiftUI

struct Loading: View {
    var onFinish: () -> Void = {}

    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let barWidth = geometry.size.width * 0.6
            let iconWidth = geometry.size.width * 0.7

            ZStack {
                GradientBackgroundView()

                VStack {
                    Spacer()

                    VStack(spacing: 20) {
                        Image("app_bg_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: iconWidth)

                        Text("VibroMate")
                            .font(.custom("SFProDisplay-Heavy", size: 28))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Text("\(Int(progress * 100))%")
                            .font(.custom("SFProDisplay-Regular", size: 18))
                            .foregroundColor(.white)

                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: barWidth, height: 8)

                            Capsule()
                                .fill(Color.white)
                                .frame(width: barWidth * progress, height: 8)
                                .animation(
                                    .easeInOut(duration: 0.2),
                                    value: progress
                                )
                        }
                    }
                    .padding(.bottom, 50)
                    .frame(height: 50)
                }
                .padding(.horizontal, 20)

            }
        }
        .task {
            progress = 0

            for step in 1...100 {
                try? await Task.sleep(nanoseconds: 20_000_000)
                guard !Task.isCancelled else { return }

                progress = CGFloat(step) / 100
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }

            onFinish()
        }
    }
}

#Preview {
    Loading()
}
