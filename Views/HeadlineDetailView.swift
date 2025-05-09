import SwiftUI

struct HeadlineDetailView: View {
    let headline: HeadlineSummary
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Article header
                VStack(alignment: .leading, spacing: 8) {
                    // Source and date info
                    HStack {
                        Text(headline.sourceName.uppercased())
                            .font(MaterialTheme.Typography.overline)
                            .foregroundColor(MaterialTheme.primary)
                        
                        Spacer()
                        
                        Text(headline.publishedAt, style: .date)
                            .font(MaterialTheme.Typography.caption)
                            .foregroundColor(MaterialTheme.onSurface.opacity(0.7))
                    }
                    
                    // Article title
                    Text(headline.title)
                        .font(MaterialTheme.Typography.headline5)
                        .foregroundColor(MaterialTheme.onSurface)
                }
                .padding(.horizontal)
                
                // Feature image (if available)
                if let imageUrlString = headline.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .foregroundColor(MaterialTheme.onSurface.opacity(0.5))
                                .frame(maxWidth: .infinity)
                        case .empty:
                            ProgressView()
                                .tint(MaterialTheme.primary)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // Description (if available)
                if let description = headline.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(MaterialTheme.Typography.subtitle1)
                            .foregroundColor(MaterialTheme.primary)
                        
                        Text(description)
                            .font(MaterialTheme.Typography.body1)
                            .foregroundColor(MaterialTheme.onSurface)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .materialCard()
                    .padding(.horizontal)
                }
                
                // AI Summary section
                if let summary = headline.summary, !summary.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("AI Summary")
                                .font(MaterialTheme.Typography.subtitle1)
                                .foregroundColor(MaterialTheme.primary)
                            
                            Spacer()
                            
                            if let generatedAt = headline.summaryGeneratedAt {
                                Text("Generated: \(generatedAt, style: .relative)")
                                    .font(MaterialTheme.Typography.caption)
                                    .foregroundColor(MaterialTheme.onSurface.opacity(0.6))
                            }
                        }
                        
                        Text(summary)
                            .font(MaterialTheme.Typography.body1)
                            .foregroundColor(MaterialTheme.onSurface)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .materialCard()
                    .padding(.horizontal)
                }
                
                // Read original article button
                if let url = URL(string: headline.url) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "safari")
                            Text("Read Full Article")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                        .padding()
                        .background(MaterialTheme.secondary)
                        .foregroundColor(MaterialTheme.onSecondary)
                        .cornerRadius(4)
                    }
                    .materialElevation(2)
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
            .padding(.vertical)
        }
        .background(MaterialTheme.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Create sample data for preview
    let sampleDate = ISO8601DateFormatter().date(from: "2025-04-19T05:48:31Z") ?? Date()
    let headline = HeadlineSummary(
        id: 1,
        title: "Supreme Court blocks, for now, new deportations under 18th century wartime law",
        description: "In a brief order, the court directed the Trump administration not to remove Venezuelans held in the Bluebonnet Detention Center \"until further order of this court.\"",
        url: "https://www.npr.org/2025/04/19/g-s1-61385/supreme-court-block-deportations",
        imageUrl: "https://npr.brightspotcdn.com/dims3/default/strip/false/crop/3514x1977+0+183/resize/1400/quality/100/format/jpeg/?url=http%3A%2F%2Fnpr-brightspot.s3.amazonaws.com%2F7d%2Fc7%2Fd893dbee461482a7c38d7f4b6308%2Fap25089757696727.jpg",
        summary: "The Supreme Court has issued a temporary block on deportations of Venezuelan migrants under the Alien Enemies Act, an 18th-century wartime law. The court's order prevents the Trump administration from removing Venezuelans held at the Bluebonnet Detention Center while legal challenges proceed. The administration had invoked the rarely-used 1798 law, which allows for detention and deportation of citizens from hostile nations during declared wars or invasions. Legal experts have questioned the law's applicability since no formal war has been declared with Venezuela. The ACLU, representing the detained migrants, argues the administration is improperly applying a \"dusty and dangerous\" statute. The case will likely move through the courts in the coming months, with significant implications for executive power and immigration policy.",
        publishedAt: sampleDate,
        summaryGeneratedAt: Date().addingTimeInterval(-3600), // 1 hour ago
        sourceName: "NPR",
        sourceUrl: "https://www.npr.org/"
    )
    
    NavigationView {
        HeadlineDetailView(headline: headline)
    }
} 