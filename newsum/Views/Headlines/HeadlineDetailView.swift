//
//  HeadlineDetailView.swift
//  newsum
//
//  Created by Li Li on 4/21/25.
//

import SwiftUI

// Create a simple placeholder for the destination of the NavigationLink
struct HeadlineDetailView: View {
    let headline: HeadlineSummary
    var body: some View {
        ScrollView { // Allow scrolling for potentially long content
            VStack(alignment: .leading, spacing: 15) {
                Text(headline.title)
                    .font(.title3)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    Text("Source:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let srcURL = URL(string: headline.sourceUrl) {
                        Link(headline.sourceName, destination: srcURL)
                            .font(.subheadline)
                    } else {
                        Text(headline.sourceName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                 Text("Published: \(headline.publishedAt, style: .date) at \(headline.publishedAt, style: .time)")
                     .font(.subheadline)
                     .foregroundColor(.gray)

                Divider()

                Text(headline.summary) // Or headline.summary if more appropriate
                    .font(.system(.body, design: .serif))
                    // Add line spacing for better readability
                    .lineSpacing(5)
                
                Divider()

                 if let url = URL(string: headline.url) {
                     Link("Read full story", destination: url)
                        .padding(.top)
                 }

                Spacer() // Push content to top
            }
            .padding()
        }
        .navigationTitle("Details") // Title for the detail view
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    // 1. Create a sample HeadlineSummary
    let sampleHeadline = HeadlineSummary(
        title: "Local Community Garden Flourishes This Spring",
        description: "Volunteers celebrate a successful planting season.",
        url: "https://example.com/news/garden",
        imageUrl: nil, // or a real URL string
        summary: "The community garden has sprung to life with dozens of new plantings, thanks to local volunteers...",
        publishedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        summaryGeneratedAt: Calendar.current.date(byAdding: .hour, value: -20, to: Date())!,
        sourceName: "Local Gazette",
        sourceUrl: "https://localgazette.com"
    )

    // 2. Wrap in a NavigationStack so the nav‐title shows
    NavigationStack {
        HeadlineDetailView(headline: sampleHeadline)
    }
}
