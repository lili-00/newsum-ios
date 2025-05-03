import SwiftUI

struct HeadlineRow: View {
    let headline: HeadlineSummary
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // AsyncImage for loading image from URL
            if let imageUrlString = headline.imageUrl, let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) {
                    phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(8)
                    case .failure(_):
                        // Placeholder for failed image load
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    case .empty:
                        // Placeholder while loading
                        ProgressView()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity, alignment: .center)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                 // Placeholder if no image URL
                 Image(systemName: "photo")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(height: 200)
                     .foregroundColor(.gray)
                     .frame(maxWidth: .infinity, alignment: .center)
            }

            // Source Name (Uppercase)
            Text(headline.sourceName.uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // Title
            Text(headline.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(3) // Limit title lines

            // Published Time (Relative)
            Text(headline.publishedAt, style: .relative)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8) // Add some vertical padding between items
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColorForMode)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // Custom background color based on color scheme
    private var backgroundColorForMode: Color {
        if colorScheme == .dark {
            // Use a dark gray instead of black for dark mode
            return Color(UIColor.systemGray6) // A lighter gray that's not too black
        } else {
            return Color.white
        }
    }
}

// Add a preview provider for HeadlineRow (Optional but recommended)
#Preview {
    // Create sample data for preview
    let sampleDate = ISO8601DateFormatter().date(from: "2025-04-19T05:48:31Z") ?? Date()
    let sampleHeadline = HeadlineSummary(
        title: "Supreme Court blocks, for now, new deportations under 18th century wartime law",
        description: "In a brief order, the court directed the Trump administration not to remove Venezuelans held in the Bluebonnet Detention Center \"until further order of this court.\"",
        url: "https://www.npr.org/2025/04/19/g-s1-61385/supreme-court-block-deportations",
        imageUrl: "https://npr.brightspotcdn.com/dims3/default/strip/false/crop/3514x1977+0+183/resize/1400/quality/100/format/jpeg/?url=http%3A%2F%2Fnpr-brightspot.s3.amazonaws.com%2F7d%2Fc7%2Fd893dbee461482a7c38d7f4b6308%2Fap25089757696727.jpg",
        summary: "Long summary text...",
        publishedAt: sampleDate,
        summaryGeneratedAt: Date(),
        sourceName: "NPR",
        sourceUrl: "https://www.npr.org/"
    )
    
    Group {
        HeadlineRow(headline: sampleHeadline)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        HeadlineRow(headline: sampleHeadline)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 