import Foundation

struct HeadlinePreview: Codable, Identifiable {
    let id: Int
    let title: String
    let sourceName: String
    let publishedAt: Date
    let imageUrl: String?
    
    // CodingKeys to map snake_case JSON to camelCase Swift properties
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case sourceName = "source_name"
        case publishedAt = "published_at"
        case imageUrl = "image_url"
    }
} 