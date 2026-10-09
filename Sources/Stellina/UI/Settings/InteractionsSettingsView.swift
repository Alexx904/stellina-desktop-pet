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
                        Button("Suono Coccole 🎵") {
                            SoundManager.shared.play(.patPat)
                        }
                        .buttonStyle(.bordered)

                        Button("Suono Pappa 🥕") {
                            SoundManager.shared.play(.eat)
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

                    Text("Quando Stellina dorme, sfiora il mouse su di lei per svegliarla dolcemente. Puoi anche metterla a dormire o svegliarla in qualsiasi momento dal menu del tasto destro o dalla StatusBar.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Alimentazione & Snack Preferiti 🥕🦴🐟").font(.headline)) {
                Picker("Snack Attuale:", selection: $settings.selectedFood) {
                    ForEach(FoodType.allCases) { food in
                        Text("\(food.emoji) \(food.displayName)").tag(food)
                    }
                }
                .pickerStyle(.menu)

                Text("Puoi lanciare il cibo cliccando con il tasto destro sul pet o dalla barra dei menu. Il cibo cade per gravità: puoi afferrarlo e trascinarlo vicino al pet per farglielo sgranocchiare con particelle a tema!")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Spacer()
                    Button("Lancia \(settings.selectedFood.displayName) \(settings.selectedFood.emoji) Ora") {
                        CarrotManager.shared.spawnCarrot(foodType: settings.selectedFood)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }

        .padding(20)
    }
}
