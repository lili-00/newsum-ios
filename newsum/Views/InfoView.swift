import SwiftUI

struct SettingsView: View {
    @AppStorage("textSizeMultiplier") private var textSizeMultiplier: Double = 1.0
    
    var body: some View {
        NavigationView {
            List {
                // Text Size Section
                Section(header: Text("Reading")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Text Size")
                            .font(.headline)
                        
                        HStack {
                            Text("A")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Slider(value: $textSizeMultiplier, in: 0.8...1.4, step: 0.1)
                                .accentColor(.blue)
                            
                            Text("A")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                        
                        // Preview text
                        Text("Preview text at current size")
                            .font(.system(size: 17 * textSizeMultiplier))
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
                
                // About Section
                Section(header: Text("About")) {
                    // App Info
                    HStack(spacing: 16) {
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading) {
                            Text("Newsum")
                                .font(.headline)
                            Text("Version \(appVersion())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // About Text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Newsum provides summaries of the headlines from various top sources and updated hourly. The app is all you need for crucial information. Stop you from endless scrolling.")
                            .font(.system(size: 15 * textSizeMultiplier))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }

    // Helper function to get app version
    private func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    // Helper function to get build number
    private func buildNumber() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
}

#Preview {
    SettingsView()
}
