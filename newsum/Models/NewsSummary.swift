import Foundation

struct NewsSummary: Codable, Identifiable {
    let articleId: String
    let title: String
    let referenceUrl: String
    let description: String?
    let keywords: [String]?
    let sourceName: String
    let pubDate: String? // Keep as String for now, can parse later if needed
    let summary: String
    let summaryGeneratedAt: String // Keep as String
    let publicationDate: String? // Keep as String

    // Conform to Identifiable using articleId
    var id: String { articleId }

    // Map JSON keys (snake_case) to Swift properties (camelCase)
    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case title
        case referenceUrl = "reference_url"
        case description
        case keywords
        case sourceName = "source_name"
        case pubDate
        case summary
        case summaryGeneratedAt = "summary_generated_at"
        case publicationDate = "publication_date"
    }
} 