import SwiftUI

struct HeadlinePreviewRow: View {
    let preview: HeadlinePreview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image if available
            if let imageUrlString = preview.imageUrl, let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(8)
                    case .failure(_):
                        // Placeholder for failed image load
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 160)
                            .foregroundColor(MaterialTheme.onSurface.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .center)
                    case .empty:
                        // Placeholder while loading
                        ProgressView()
                            .tint(MaterialTheme.primary)
                            .frame(height: 160)
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
                     .frame(height: 160)
                     .foregroundColor(MaterialTheme.onSurface.opacity(0.5))
                     .frame(maxWidth: .infinity, alignment: .center)
            }

            // Source Name (Uppercase)
            Text(preview.sourceName.uppercased())
                .font(MaterialTheme.Typography.overline)
                .foregroundColor(MaterialTheme.onSurface.opacity(0.7))
                .padding(.top, 4)

            // Title
            Text(preview.title)
                .font(MaterialTheme.Typography.subtitle1)
                .foregroundColor(MaterialTheme.onSurface)
                .lineLimit(2) // Limit title lines for the preview

            // Published Time (Relative)
            Text(preview.publishedAt, style: .relative)
                .font(MaterialTheme.Typography.caption)
                .foregroundColor(MaterialTheme.onSurface.opacity(0.6))
                .padding(.bottom, 4)
        }
        .padding(.vertical, 0)
        .padding(.horizontal, 0)
        .materialCard()
        .materialElevation(1)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    // Create sample data for preview
    let sampleDate = ISO8601DateFormatter().date(from: "2025-04-19T05:48:31Z") ?? Date()
    let preview = HeadlinePreview(
        id: 1,
        title: "Supreme Court blocks, for now, new deportations under 18th century wartime law",
        sourceName: "NPR",
        publishedAt: sampleDate,
        imageUrl: "https://npr.brightspotcdn.com/dims3/default/strip/false/crop/3514x1977+0+183/resize/1400/quality/100/format/jpeg/?url=http%3A%2F%2Fnpr-brightspot.s3.amazonaws.com%2F7d%2Fc7%2Fd893dbee461482a7c38d7f4b6308%2Fap25089757696727.jpg"
    )
    
    Group {
        HeadlinePreviewRow(preview: preview)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        HeadlinePreviewRow(preview: preview)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 