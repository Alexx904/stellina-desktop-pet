import SwiftUI

public struct PhysicsSettingsView: View {
    @ObservedObject var settings = PetSettings.shared

    public init() {}

    public var body: some View {
        Form {
            Section(header: Text("Dimensioni & Proporzioni").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Dimensione Pet:")
                        Spacer()
                        Text("\(Int(settings.windowSize)) px")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.windowSize, in: 80...300, step: 10)
                    Text("Regola la grandezza del personaggio sullo schermo.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Movimento & Fisica").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Velocità Camminata:")
                        Spacer()
                        Text(String(format: "%.1f", settings.walkSpeed))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.walkSpeed, in: 1.0...10.0, step: 0.5)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Forza di Gravità:")
                        Spacer()
                        Text(String(format: "%.1f", settings.gravity))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.gravity, in: 0.5...5.0, step: 0.5)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Frequenza Fotogrammi (Frame Delay):")
                        Spacer()
                        Text("\(settings.animSpeedTicks) tick")
                            .foregroundColor(.secondary)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(settings.animSpeedTicks) },
                            set: { settings.animSpeedTicks = Int($0) }
                        ),
                        in: 2...12,
                        step: 1
                    )
                    Text("Valore più basso = cambio fotogramma più rapido.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Preset Rapidi").font(.headline)) {
                HStack(spacing: 12) {
                    Button("Calmo") {
                        settings.walkSpeed = 2.0
                        settings.gravity = 1.5
                        settings.animSpeedTicks = 8
                    }
                    Button("Standard") {
                        settings.walkSpeed = 4.0
                        settings.gravity = 2.0
                        settings.animSpeedTicks = 5
                    }
                    Button("Vivace") {
                        settings.walkSpeed = 7.0
                        settings.gravity = 3.0
                        settings.animSpeedTicks = 3
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
    }
}
