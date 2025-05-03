//
//  HeadlineRow.swift
//  newsum
//
//  Created by Li Li on 4/20/25.
//

import Foundation
import SwiftUI

struct HeadlineRow: View {
    let headline: HeadlineSummary
    @AppStorage("textSizeMultiplier") private var textSizeMultiplier: Double = 1.0

    var body: some View {
        // Wrap the entire content in a card-like container
        VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .center, spacing: 12) { // Align items to the top
            // Image using AsyncImage
            AsyncImage(url: URL(string: headline.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    // Placeholder while loading
                    ProgressView()
                        .frame(width: 80, height: 80) // Maintain size consistency
                case .success(let image):
                    // Display the loaded image
                    image
                        .resizable()
                        .scaledToFill()
//                            .aspectRatio(contentMode: .) // Fill the frame
                        .frame(width: 80, height: 80)   // Fixed frame size
                        .clipped()                       // Clip excess
                        .clipShape(RoundedRectangle(cornerRadius: 8)) // Rounded corners
                case .failure:
                    // Placeholder for error or missing URL
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 60, alignment: .center)
                        .foregroundColor(.secondary)
                        .background(Color(.systemGray5)) // Subtle background
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView() // Handle future cases
                }
            }

            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                // Source Name - Smaller, medium weight
                Text(headline.sourceName)
                        .font(.system(size: 11 * textSizeMultiplier, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1) // Ensure source doesn't wrap excessively

                // Title - Regular weight, allows multiple lines
                Text(headline.title)
                        .font(.system(size: 16 * textSizeMultiplier, weight: .semibold))
                    .lineLimit(3) // Allow title to wrap

                // Published Date - Relative format
                Text(headline.publishedAt, style: .relative) // E.g., "5 minutes ago"
                        .font(.system(size: 12 * textSizeMultiplier))
                    .foregroundColor(.gray)
                    .padding(.top, 2) // Add slight space above the date
            }
            Spacer() // Push content to the left
        }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius:.pi * 2)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    // Sample data for previewing HeadlineRow
    let sampleHeadline = HeadlineSummary(
        // id is generated automatically
        title: "Major Tech Announcement Expected Next Week From Apple",
        description: "Rumors swirl about a new product launch.",
        url: "https://example.com/news/tech-announcement",
        imageUrl: "https://images.unsplash.com/photo-1517430816045-df4b7de11d1d", // Example image URL
        summary: "A brief summary of the expected announcement...",
        publishedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, // Example: 2 hours ago
        summaryGeneratedAt: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
        sourceName: "TechCrunch",
        sourceUrl: "https://techcrunch.com"
    )

    let sampleHeadlineNoImage = HeadlineSummary(
        title: "Local Community Garden Flourishes This Spring",
        description: "Volunteers celebrate a successful planting season.",
        url: "https://example.com/news/garden",
        imageUrl: nil, // No image URL
        summary: "The community garden...",
        publishedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // Example: Yesterday
        summaryGeneratedAt: Calendar.current.date(byAdding: .hour, value: -20, to: Date())!,
        sourceName: "Local Gazette",
        sourceUrl: "https://localgazette.com"
    )

    return ScrollView {
        VStack(spacing: 0) {
        HeadlineRow(headline: sampleHeadline)
        HeadlineRow(headline: sampleHeadlineNoImage)
    }
    }
    .background(Color(.systemGroupedBackground))
}
