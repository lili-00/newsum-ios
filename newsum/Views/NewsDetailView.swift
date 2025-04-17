import SwiftUI

struct NewsDetailView: View {
    let summary: NewsSummary

    var body: some View {
        ScrollView { // Use ScrollView for potentially long content
            VStack(alignment: .leading, spacing: 16) {
                Text(summary.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    Text("Source: \(summary.sourceName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    // Optionally add publication date here
                    // if let dateStr = summary.publicationDate, let formattedDate = formatDate(dateStr) {
                    //     Text(formattedDate)
                    //         .font(.subheadline)
                    //         .foregroundColor(.secondary)
                    // }
                }

                Divider()

                Text(summary.summary)
                    .font(.body)

                // Optionally display description if available
                if let description = summary.description, !description.isEmpty {
                    Divider()
                    Text("Original Description:")
                        .font(.headline)
                        .padding(.top)
                    Text(description)
                        .font(.body)
                }
                
                // Optional: Link to the original article
                if let url = URL(string: summary.referenceUrl) {
                    Divider()
                    Link("Read Full Article", destination: url)
                        .padding(.top)
                }

                Spacer() // Push content to the top
            }
            .padding()
        }
        .navigationTitle("Details") // Set a title for the detail view
        .navigationBarTitleDisplayMode(.inline) // Use inline style for potentially long article titles
    }
    
    // Optional: Date formatting helper (can be moved to a utility file)
    /*
    private func formatDate(_ dateString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date.formatted(date: .long, time: .shortened)
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date.formatted(date: .long, time: .shortened)
            }
        }
        return dateString // Return original if parsing fails
    }
    */
}

#Preview {
    NavigationView { // Wrap in NavigationView for preview
        NewsDetailView(summary: NewsSummary(
            articleId: "preview-detail-1",
            title: "This Is the Full Article Title Which Might Be Quite Long",
            referenceUrl: "https://example.com/detail",
            description: "This is the longer, original description field provided by the API. It might contain more raw text or context than the summary.",
            keywords: ["detail", "preview"],
            sourceName: "Detailed News Source",
            pubDate: "2025-04-17T09:00:00Z",
            summary: "This is the generated summary text. It provides a concise overview of the article's main points, intended for quick reading in the list view.",
            summaryGeneratedAt: "2025-04-17T10:30:00Z",
            publicationDate: "2025-04-17T09:00:00Z"
        ))
    }
} 