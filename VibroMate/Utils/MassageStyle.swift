import CoreHaptics

enum MassageStyle: String, CaseIterable {

    case pulse, breeze, storm, bigWave, smallWave,
        eruption, space, comet, ship, harp, drums, auger

    var events: [CHHapticEvent] {
        switch self {

        case .pulse:
            return [
                Self.beat(time: 0.00, intensity: 0.95, sharp: 0.45),
                Self.beat(time: 0.16, intensity: 0.55, sharp: 0.35),
                Self.beat(time: 0.82, intensity: 0.90, sharp: 0.45),
                Self.beat(time: 0.98, intensity: 0.50, sharp: 0.35),
            ]

        case .harp:
            return [
                Self.beat(time: 0.00, intensity: 0.52, sharp: 0.78),
                Self.beat(time: 0.09, intensity: 0.44, sharp: 0.72),
                Self.beat(time: 0.19, intensity: 0.36, sharp: 0.66),
                Self.beat(time: 0.32, intensity: 0.28, sharp: 0.56),
                Self.beat(time: 0.49, intensity: 0.22, sharp: 0.46),
                Self.beat(time: 0.72, intensity: 0.16, sharp: 0.36),
            ]

        case .drums:
            return [
                Self.beat(time: 0.00, intensity: 1.00, sharp: 0.95),
                Self.beat(time: 0.18, intensity: 0.45, sharp: 0.70),
                Self.beat(time: 0.36, intensity: 0.70, sharp: 0.82),
                Self.beat(time: 0.72, intensity: 1.00, sharp: 0.95),
                Self.beat(time: 0.90, intensity: 0.55, sharp: 0.72),
                Self.beat(time: 1.08, intensity: 0.75, sharp: 0.86),
            ]

        case .breeze:
            return Self.wave(start: 0.00, duration: 1.85, from: 0.08, to: 0.38, sharp: 0.12)
                + Self.wave(start: 2.10, duration: 1.65, from: 0.10, to: 0.32, sharp: 0.10)

        case .ship:
            return Self.continuous(start: 0.00, duration: 2.20, intensity: 0.22, sharp: 0.14)
                + [
                    Self.beat(time: 0.00, intensity: 0.52, sharp: 0.22),
                    Self.beat(time: 0.46, intensity: 0.38, sharp: 0.18),
                    Self.beat(time: 0.92, intensity: 0.50, sharp: 0.22),
                    Self.beat(time: 1.38, intensity: 0.36, sharp: 0.18),
                    Self.beat(time: 1.84, intensity: 0.48, sharp: 0.22),
                ]

        case .bigWave:
            return Self.wave(start: 0.00, duration: 2.10, from: 0.18, to: 0.95, sharp: 0.24)
                + Self.wave(start: 2.35, duration: 1.70, from: 0.12, to: 0.70, sharp: 0.20)

        case .smallWave:
            return stride(from: 0.0, through: 2.10, by: 0.42).flatMap { t in
                Self.wave(start: t, duration: 0.30, from: 0.14, to: 0.46, sharp: 0.22)
            }

        case .storm:
            return Self.continuous(start: 0.00, duration: 1.55, intensity: 0.16, sharp: 0.35)
                + [
                    Self.beat(time: 0.08, intensity: 0.80, sharp: 0.95),
                    Self.beat(time: 0.19, intensity: 1.00, sharp: 1.00),
                    Self.beat(time: 0.43, intensity: 0.62, sharp: 0.86),
                    Self.beat(time: 0.50, intensity: 0.92, sharp: 1.00),
                    Self.beat(time: 0.84, intensity: 0.74, sharp: 0.92),
                    Self.beat(time: 1.05, intensity: 1.00, sharp: 1.00),
                    Self.beat(time: 1.29, intensity: 0.58, sharp: 0.82),
                ]

        case .eruption:
            return Self.continuous(start: 0.00, duration: 0.42, intensity: 0.20, sharp: 0.28)
                + Self.continuous(start: 0.42, duration: 0.36, intensity: 0.42, sharp: 0.38)
                + Self.continuous(start: 0.78, duration: 0.30, intensity: 0.68, sharp: 0.52)
                + [
                    Self.beat(time: 1.08, intensity: 0.95, sharp: 0.88),
                    Self.beat(time: 1.16, intensity: 1.00, sharp: 1.00),
                    Self.beat(time: 1.25, intensity: 0.88, sharp: 0.92),
                ]
                + Self.continuous(start: 1.32, duration: 0.45, intensity: 0.28, sharp: 0.30)

        case .auger:
            return Self.continuous(start: 0.00, duration: 1.25, intensity: 0.58, sharp: 0.92)
                + stride(from: 0.0, through: 1.20, by: 0.12).map {
                    Self.beat(time: $0, intensity: 0.46, sharp: 1.0)
                }

        case .space:
            return [
                Self.beat(time: 0.00, intensity: 0.20, sharp: 0.08),
                Self.beat(time: 1.35, intensity: 0.16, sharp: 0.06),
                Self.beat(time: 2.85, intensity: 0.24, sharp: 0.10),
            ]

        case .comet:
            return [
                Self.beat(time: 0.00, intensity: 0.95, sharp: 0.72),
            ]
                + Self.continuous(start: 0.07, duration: 0.18, intensity: 0.72, sharp: 0.46)
                + Self.continuous(start: 0.25, duration: 0.34, intensity: 0.42, sharp: 0.28)
                + Self.continuous(start: 0.59, duration: 0.55, intensity: 0.16, sharp: 0.14)
        }
    }

    var displayName: String {
        switch self {
        case .pulse: return "Pulse"
        case .breeze: return "Breeze"
        case .storm: return "Storm"
        case .bigWave: return "Big Wave"
        case .smallWave: return "Small Wave"
        case .eruption: return "Eruption"
        case .space: return "Space"
        case .comet: return "Comet"
        case .ship: return "Ship"
        case .harp: return "Harp"
        case .drums: return "Drums"
        case .auger: return "Auger"
        }
    }

    private static func beat(
        time: Double,
        intensity: Float,
        sharp: Float = 0.8
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: intensity
                ),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: sharp
                ),
            ],
            relativeTime: time
        )
    }

    private static func continuous(
        start: Double,
        duration: Double,
        intensity: Float,
        sharp: Float
    ) -> [CHHapticEvent] {
        [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: intensity
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: sharp
                    ),
                ],
                relativeTime: start,
                duration: duration
            )
        ]
    }

    private static func wave(
        start: Double,
        duration: Double,
        from: Float,
        to: Float,
        sharp: Float = 0.3
    ) -> [CHHapticEvent] {

        let riseDur = duration * 0.30
        let peakDur = duration * 0.40
        let fallDur = duration - riseDur - peakDur

        return [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: from
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: sharp
                    ),
                ],
                relativeTime: start,
                duration: riseDur
            ),
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: to
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: sharp
                    ),
                ],
                relativeTime: start + riseDur,
                duration: peakDur
            ),
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: from
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: sharp
                    ),
                ],
                relativeTime: start + riseDur + peakDur,
                duration: fallDur
            ),
        ]
    }

    static func from(name: String) -> MassageStyle? {
        let normalizedName = name.normalizedMassageStyleName
        return Self.allCases.first {
            $0.rawValue.normalizedMassageStyleName == normalizedName
                || $0.displayName.normalizedMassageStyleName == normalizedName
        }
    }
}

private extension String {
    var normalizedMassageStyleName: String {
        lowercased().filter { $0.isLetter || $0.isNumber }
    }
}
