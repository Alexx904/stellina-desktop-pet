import SwiftUI

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        TabView {
            SpriteSettingsView()
                .tabItem {
                    Label("Sprite & Aspetto", systemImage: "photo.on.rectangle.angled")
                }

            PhysicsSettingsView()
                .tabItem {
                    Label("Fisica & Movimento", systemImage: "slider.horizontal.3")
                }

            InteractionsSettingsView()
                .tabItem {
                    Label("Interazioni & Audio", systemImage: "heart.circle")
                }

            GamificationSettingsView()
                .tabItem {
                    Label("Bisogni & Accessori", systemImage: "sparkles")
                }

            aboutTab
                .tabItem {
                    Label("Informazioni", systemImage: "info.circle")
                }
        }
        .frame(width: 540, height: 500)
    }

    private var aboutTab: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("🐾")
                .font(.system(size: 64))

            VStack(spacing: 6) {
                Text("Stellina Desktop Pet")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Versione 1.1.0 per macOS")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Box Ideatore
            VStack(spacing: 4) {
                Text("Ideato con passione da")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Alessandro Miniello")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.12)))

            Text("Un compagno virtuale leggero, nativo e battery-friendly per il tuo Mac.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 40)


            HStack(spacing: 16) {
                Button("Riposiziona al Centro") {
                    BehaviorSystem.shared.resetToInitialPosition()
                }

                Button("Chiudi Stellina") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }
}
