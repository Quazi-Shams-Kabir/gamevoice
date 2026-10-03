import SwiftUI
import LiveKit

struct ContentView: View {
    @StateObject private var room = Room()

    @AppStorage("lkURL") private var url = "wss://YOUR-PROJECT.livekit.cloud"
    @AppStorage("lkToken") private var token = ""
    @State private var micOn = true
    @State private var error: String?

    private var connected: Bool { room.connectionState == .connected }

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("wss:// URL", text: $url)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                    TextField("Token (from make_token.py)", text: $token, axis: .vertical)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .lineLimit(1...3)
                }

                Section {
                    Button(connected ? "Leave" : "Join") { Task { await toggle() } }
                    if connected {
                        Toggle("Mic", isOn: $micOn)
                            .onChange(of: micOn) { _, on in
                                Task { try? await room.localParticipant.setMicrophone(enabled: on) }
                            }
                    }
                    Text("State: \(String(describing: room.connectionState))").font(.footnote)
                    if let error { Text(error).foregroundStyle(.red).font(.footnote) }
                }

                if connected {
                    Section("In room") {
                        Text("You")
                        ForEach(Array(room.remoteParticipants.values), id: \.sid) { p in
                            HStack {
                                Text(p.identity?.stringValue ?? "?")
                                Spacer()
                                if p.isSpeaking { Image(systemName: "waveform") }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Squad Voice")
        }
    }

    private func toggle() async {
        error = nil
        if connected {
            await room.disconnect()
            return
        }
        do {
            try GameAudio.configure()
            try await room.connect(url: url, token: token)
            try await room.localParticipant.setMicrophone(enabled: micOn)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
