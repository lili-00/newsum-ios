import SwiftUI

// Shared date formatter instance
private let isoDateFormatterForRow = ISO8601DateFormatter()

struct NewsRow: View {
    let summary: NewsSummary

    // Computed property to parse publication date
    private var parsedPublicationDate: Date? {
        guard let dateString = summary.publicationDate ?? summary.pubDate else { return nil }
        isoDateFormatterForRow.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoDateFormatterForRow.date(from: dateString) {
            return date
        }
        isoDateFormatterForRow.formatOptions = [.withInternetDateTime]
        return isoDateFormatterForRow.date(from: dateString)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) { // Reduced spacing
            // Source Name - Smaller, medium weight
            Text(summary.sourceName)
                .font(.caption) 
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.bottom, 2) // Add slight space before title

            // Title - Larger, bold, allows multiple lines
            Text(summary.title)
                .font(.title3) // Slightly smaller than detail title
                .fontWeight(.bold)
                .lineLimit(3) // Allow more lines for the title
            
            // Metadata - Relative date
            if let date = parsedPublicationDate {
                Text(date, style: .date) // Changed from .relative to .date
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 4) // Add space above metadata
            } else {
                 // Optional: Placeholder or hide if no date
                 Text("Recently") // Simple fallback
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 10) // Adjust vertical padding for the row
    }
}

// Add a preview provider for easier design iteration
#Preview {
    List {
         NewsRow(summary: NewsSummary(
            articleId: "preview-1",
            title: "Preview Title: This is a Much Longer Headline to Test Line Limiting and Wrapping Behavior",
            referenceUrl: "https://example.com",
            description: "Optional description text.",
            keywords: ["preview", "test"],
            sourceName: "Preview Source",
            pubDate: "2025-04-18T18:30:00Z", // Example recent date
            summary: "This summary text won't be displayed in the row anymore.",
            summaryGeneratedAt: "2025-04-18T19:00:00Z",
            publicationDate: "2025-04-18T18:30:00Z" // Match pubDate for consistency
        ))
         NewsRow(summary: NewsSummary(
            articleId: "preview-2",
            title: "Another Preview Item with a Standard Length Title",
            referenceUrl: "https://example.com/2",
            description: nil,
            keywords: [],
            sourceName: "Another Source Inc.",
            pubDate: "2025-04-17T09:00:00Z", // Older date
            summary: "Another summary not shown.",
            summaryGeneratedAt: "2025-04-17T10:31:00Z",
            publicationDate: "2025-04-17T09:00:00Z"
        ))
    }
} 