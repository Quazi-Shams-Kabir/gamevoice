import SwiftUI
import LiveKit
import AVFoundation

@main
struct GameVoiceApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

/// Audio setup: mix with the game, minimal ducking.
enum GameAudio {
    static func configure() throws {
        // We own the AVAudioSession instead of LiveKit's auto-config,
        // so .mixWithOthers is guaranteed.
        AudioManager.shared.audioSession.isAutomaticConfigurationEnabled = false

        let s = AVAudioSession.sharedInstance()
        try s.setCategory(.playAndRecord,
                          mode: .default,   // .voiceChat = stronger AEC, more ducking
                          options: [.mixWithOthers, .defaultToSpeaker, .allowBluetoothA2DP])
        try s.setActive(true)

        // Voice processing (AEC) stays on; ducking kept at minimum.
        AudioManager.shared.duckingLevel = .min
        AudioManager.shared.isAdvancedDuckingEnabled = false
    }
}
