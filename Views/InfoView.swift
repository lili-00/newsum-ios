import SwiftUI

struct InfoView: View {
    var body: some View {
        // Use a ScrollView in case content grows, though not strictly needed now
        ScrollView {
            VStack(alignment: .leading, spacing: 24) { // Increased spacing
                // App Icon and Name
                HStack(spacing: 16) {
                    Image(systemName: "newspaper.fill") // Use app-relevant icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.accentColor) // Use accent color
                        .padding(12)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Circle()) // Circular background

                    Text("Newsum")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 16) // Add space below the header
                
                // Introduction Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About Newsum")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Newsum provides concise summaries of the latest news headlines, fetched from various sources and updated regularly. Stay informed quickly and efficiently.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4) // Improve readability
                }
                
                Divider() // Visual separator
                
                // Version Information
                HStack {
                    Text("App Version")
                        .font(.headline)
                    Spacer()
                    Text(appVersion() + " (" + buildNumber() + ")")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer() // Pushes content to the top
            }
            .padding() // Add padding around the entire VStack
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
    InfoView()
} 