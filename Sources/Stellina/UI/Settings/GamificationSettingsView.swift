import SwiftUI

public struct GamificationSettingsView: View {
    @ObservedObject var settings = PetSettings.shared
    @ObservedObject var needs = PetNeedsManager.shared

    public init() {}

    public var body: some View {
        Form {
            Section(header: Text("Sistema Bisogni & Benessere (Tamagotchi)").font(.headline)) {
                Toggle("Abilita Gamification (Coccole & Fame)", isOn: $settings.gamificationEnabled)

                if settings.gamificationEnabled {
                    VStack(alignment: .leading, spacing: 14) {
                        // Barra Coccole
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Coccole & Affetto:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(needs.affection))% 💖")
                                    .foregroundColor(needs.isAffectionLow ? .red : .secondary)
                                    .fontWeight(needs.isAffectionLow ? .bold : .regular)
                            }
                            ProgressView(value: needs.affection, total: 100.0)
                                .accentColor(needs.isAffectionLow ? .pink : .purple)

                            HStack {
                                Text(needs.isAffectionLow ? "🥺 Stellina si sente sola, coccolala!" : "Stellina è felice e amata!")
                                    .font(.caption)
                                    .foregroundColor(needs.isAffectionLow ? .red : .secondary)
                                Spacer()
                                Button("Fai Coccole 💖") {
                                    BehaviorSystem.shared.pet()
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }

                        Divider()

                        // Barra Sazietà / Fame
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Sazietà & Nutrizione:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(needs.fullness))% 🥕")
                                    .foregroundColor(needs.isFullnessLow ? .orange : .secondary)
                                    .fontWeight(needs.isFullnessLow ? .bold : .regular)
                            }
                            ProgressView(value: needs.fullness, total: 100.0)
                                .accentColor(needs.isFullnessLow ? .orange : .green)

                            HStack {
                                Text(needs.isFullnessLow ? "🤤 Stellina ha fame, dalle una carota!" : "Pancino pieno e soddisfatto!")
                                    .font(.caption)
                                    .foregroundColor(needs.isFullnessLow ? .orange : .secondary)
                                Spacer()
                                Button("Lancia Carota 🥕") {
                                    CarrotManager.shared.spawnCarrot()
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }

                        Divider()

                        Toggle("Mostra Badge Emoji sotto soglia critica (< 25%)", isOn: $settings.showNeedBadges)

                        Text("Se le coccole scendono sotto il 25% compare l'emoji 🥺 con cuori spenti. Se ha fame compare l'emoji 🤤 e il pancino borbotta dolcemente.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Slider Decadimento Coccole
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Durata ricarica Coccole:")
                                Spacer()
                                Text("\(Int(settings.affectionDecayMinutes)) min")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.affectionDecayMinutes, in: 3...30, step: 1)
                        }

                        // Slider Decadimento Fame
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Durata sazietà Fame:")
                                Spacer()
                                Text("\(Int(settings.hungerDecayMinutes)) min")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.hungerDecayMinutes, in: 3...30, step: 1)
                        }

                        HStack {
                            Spacer()
                            Button("Ricarica Tutto al 100% ✨") {
                                needs.resetNeeds()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section(header: Text("Funzionalità Cute Aggiuntive").font(.headline)) {
                Toggle("Inclinazione Curiosa (Curious Ear Tilt)", isOn: $settings.curiousEarTiltEnabled)
                Text("Quando muovi il cursore vicino a Stellina, la testolina si inclina incuriosita verso la direzione del mouse.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
    }
}
