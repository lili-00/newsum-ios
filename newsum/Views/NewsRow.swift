import SwiftUI

struct NewsRow: View {
    let summary: NewsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(summary.title)
                .font(.headline)
                .lineLimit(2) // Limit title to 2 lines

            Text(summary.summary)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4) // Limit summary to 4 lines

            HStack {
                Text(summary.sourceName)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                // Optional: Display publication date or generated time
                // if let dateStr = summary.publicationDate ?? summary.summaryGeneratedAt {
                //     Text(formatDate(dateStr) ?? "") // Add a date formatting function if needed
                //        .font(.caption)
                //        .foregroundColor(.gray)
                // }
            }
        }
        .padding(.vertical, 8) // Add some vertical padding for spacing between rows
    }
    
    // Optional: Helper function to format date strings if needed
    /*
    private func formatDate(_ dateString: String) -> String? {
        // Implement date parsing and formatting here
        // Example using ISO8601DateFormatter
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date.formatted(date: .abbreviated, time: .shortened)
        } else {
            // Fallback for potentially different formats
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date.formatted(date: .abbreviated, time: .shortened)
            }
        }
        return nil // Or return original string if parsing fails
    }
    */
}

// Add a preview provider for easier design iteration
#Preview {
    List {
         NewsRow(summary: NewsSummary(
            articleId: "preview-1",
            title: "Preview Title: This is a long headline to test line limiting",
            referenceUrl: "https://example.com",
            description: "Optional description text.",
            keywords: ["preview", "test"],
            sourceName: "Preview Source",
            pubDate: nil,
            summary: "This is a preview summary of the news article. It should be long enough to potentially wrap multiple lines, up to the limit set in the view code. More text goes here to fill it out.",
            summaryGeneratedAt: "2025-04-17T10:30:00Z",
            publicationDate: nil
        ))
         NewsRow(summary: NewsSummary(
            articleId: "preview-2",
            title: "Another Preview Item",
            referenceUrl: "https://example.com/2",
            description: nil,
            keywords: [],
            sourceName: "Another Source",
            pubDate: "2025-04-17T09:00:00Z",
            summary: "A shorter summary.",
            summaryGeneratedAt: "2025-04-17T10:31:00Z",
            publicationDate: "2025-04-17T09:00:00Z"
        ))
    }
} 