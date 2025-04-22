import Foundation

struct HeadlineSummary: Codable, Identifiable {
    let id = UUID() // Add identifiable conformance for use in SwiftUI Lists
    let title: String
    let description: String
    let url: String
    let imageUrl: String? // Make optional as sometimes it might be missing
    let summary: String
    let publishedAt: Date
    let summaryGeneratedAt: Date
    let sourceName: String
    let sourceUrl: String

    // Use CodingKeys to map snake_case JSON keys to camelCase Swift properties
    enum CodingKeys: String, CodingKey {
        case title, description, url
        case imageUrl = "image_url"
        case summary
        case publishedAt = "published_at"
        case summaryGeneratedAt = "summary_generated_at"
        case sourceName = "source_name"
        case sourceUrl = "source_url"
    }
} 