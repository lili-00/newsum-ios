import SwiftUI

// Helper to parse ISO8601 dates
private let isoDateFormatter = ISO8601DateFormatter()

struct SummaryDetailView: View {
    let summary: NewsSummary

    // Computed property to parse and potentially format the date
    private var parsedPublicationDate: Date? {
        guard let dateString = summary.publicationDate else { return nil }
        // Attempt parsing common ISO8601 formats
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoDateFormatter.date(from: dateString) {
            return date
        }
        isoDateFormatter.formatOptions = [.withInternetDateTime]
        return isoDateFormatter.date(from: dateString)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(summary.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Source: \(summary.sourceName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Display formatted publication date if available and parsable
                if let date = parsedPublicationDate {
                    Text("Published: ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    + Text(date, style: .date) // Use SwiftUI's date formatting
                        .font(.caption)
                        .foregroundColor(.gray)
                } else if let pubDateString = summary.publicationDate { 
                    // Fallback to showing the raw string if parsing fails
                    Text("Published: \(pubDateString)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Divider()

                Text(summary.summary)
                    // Apply serif font for body text
                    .font(.system(.body, design: .serif))
                    // Add line spacing for better readability
                    .lineSpacing(5)
                
//                // Add keywords if available
//                if let keywords = summary.keywords, !keywords.isEmpty {
//                    Divider()
//                    Text("Keywords: \(keywords.joined(separator: ", "))")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
                
                // Add reference URL link if available
                if let url = URL(string: summary.referenceUrl) {
                    Divider()
                    Link("Read full article", destination: url)
                        .font(.callout)
                }
                
                Spacer() // Pushes content to the top

            }
            .padding()
        }
        .navigationTitle("News Summary") // Set a title for the detail view
        .navigationBarTitleDisplayMode(.inline) // Keep the title small
    }
}

// Add a preview provider
#Preview {
    NavigationView { // Wrap in NavigationView for preview context
        SummaryDetailView(summary: NewsSummary(
            articleId: "preview-detail",
            title: "Detailed Preview Title: A Longer Headline for Testing",
            referenceUrl: "https://example.com/detail",
            description: "Optional detailed description.",
            keywords: ["detail", "preview", "swiftui"],
            sourceName: "Detail Source",
            pubDate: "2025-04-18T12:00:00Z",
            summary: "This is the full summary text that will be displayed on the detail page. It provides more context than the row view and allows the user to read the entire generated summary without truncation. We can add more text here to simulate a longer summary.",
            summaryGeneratedAt: "2025-04-18T12:30:00Z",
            publicationDate: "2025-04-18T12:00:00Z"
        ))
    }
} 
