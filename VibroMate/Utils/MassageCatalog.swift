import Foundation

struct MassageMode: Identifiable {
    let style: MassageStyle
    let iconName: String
    let isLocked: Bool

    var id: String { style.rawValue }
    var name: String { style.displayName }
}

enum MassageCatalog {
    static let modes: [MassageMode] = [
        .init(style: .pulse, iconName: "ic_pulse", isLocked: false),
        .init(style: .breeze, iconName: "ic_breze", isLocked: false),
        .init(style: .storm, iconName: "ic_shtorm", isLocked: true),
        .init(style: .bigWave, iconName: "ic_wave", isLocked: true),
        .init(style: .smallWave, iconName: "ic_wave_1", isLocked: true),
        .init(style: .eruption, iconName: "ic_eruption", isLocked: true),
        .init(style: .space, iconName: "ic_space", isLocked: true),
        .init(style: .comet, iconName: "ic_comet", isLocked: true),
        .init(style: .ship, iconName: "ic_ship", isLocked: true),
        .init(style: .harp, iconName: "ic_harp", isLocked: true),
        .init(style: .drums, iconName: "ic_drums", isLocked: true),
        .init(style: .auger, iconName: "ic_auger", isLocked: true),
    ]
}
