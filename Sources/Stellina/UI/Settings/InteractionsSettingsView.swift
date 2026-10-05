import SwiftUI

public struct InteractionsSettingsView: View {
    @ObservedObject var settings = PetSettings.shared

    public init() {}

    public var body: some View {
        Form {
            Section(header: Text("Effetti Sonori").font(.headline)) {
                Toggle("Abilita Suoni", isOn: $settings.soundEnabled)

                if settings.soundEnabled {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Volume:")
                            Spacer()
                            Text("\(Int(settings.soundVolume * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.soundVolume, in: 0.1...1.0, step: 0.05)
                    }
                    .padding(.vertical, 2)

                    HStack {
                        Spacer()
                        Button("Ascolta Suono di Prova 🎵") {
                            SoundManager.shared.play(.patPat)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            Section(header: Text("Coccole & Affetto (Pat-Pat)").font(.headline)) {
                Toggle("Abilita Carezze (Pat-Pat)", isOn: $settings.petPatEnabled)

                Text("Passa il mouse a destra e a sinistra sopra Stellina per accarezzarla: una mano animata la coccolerà dolcemente facendola fare le fusa e sprigionando cuoricini ❤️.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Sonno & Riposo Naturale").font(.headline)) {
                Toggle("Addormentati dopo inattività", isOn: $settings.sleepEnabled)

                if settings.sleepEnabled {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Inattività prima del riposo:")
                            Spacer()
                            Text("\(Int(settings.sleepIdleSeconds / 60)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(
                            value: Binding(
                                get: { settings.sleepIdleSeconds / 60.0 },
                                set: { settings.sleepIdleSeconds = $0 * 60.0 }
                            ),
                            in: 1...10,
                            step: 1
                        )
                    }
                    .padding(.vertical, 2)

                    Text("Quando Stellina dorme, sfiora il mouse su di lei per svegliarla dolcemente.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
    }
}
