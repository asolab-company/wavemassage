import Combine
import CoreHaptics
import Foundation

final class VibrationManager {

    static let shared = VibrationManager()
    private init() { prepareHaptics() }

    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    private var currentStyle: MassageStyle?
    private var cancellables = Set<AnyCancellable>()
    private let settings = VibrationSettings.shared

    private var hasInitializedSubscriptions = false

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        do {
            if engine == nil {
                let newEngine = try CHHapticEngine()
                newEngine.playsHapticsOnly = true
                newEngine.resetHandler = { [weak self] in
                    self?.restartAfterEngineReset()
                }
                engine = newEngine
                observeSettingsIfNeeded()
            }

            try engine?.start()
        } catch {}
    }

    func stop() {
        currentStyle = nil
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
    }

    func play(style: MassageStyle) {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
        currentStyle = style
        prepareHaptics()

        guard let engine else { return }

        do {
            let pattern = try CHHapticPattern(
                events: style.events,
                parameters: []
            )
            let advancedPlayer = try engine.makeAdvancedPlayer(with: pattern)
            advancedPlayer.loopEnabled = true

            player = advancedPlayer
            applyCurrentSettings()
            try advancedPlayer.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    private func observeSettingsIfNeeded() {
        guard !hasInitializedSubscriptions else { return }
        hasInitializedSubscriptions = true

        settings.$speed
            .dropFirst()
            .sink { [weak self] _ in self?.applyCurrentSettings() }
            .store(in: &cancellables)

        settings.$intensity
            .dropFirst()
            .sink { [weak self] _ in self?.applyCurrentSettings() }
            .store(in: &cancellables)
    }

    private func applyCurrentSettings() {
        guard let player else { return }

        player.playbackRate = settings.speed

        let intensityParam = CHHapticDynamicParameter(
            parameterID: .hapticIntensityControl,
            value: settings.intensity.rawValue,
            relativeTime: 0
        )
        try? player.sendParameters([intensityParam], atTime: 0)
    }

    private func restartAfterEngineReset() {
        do {
            try engine?.start()
            if let currentStyle {
                play(style: currentStyle)
            }
        } catch {}
    }
}
