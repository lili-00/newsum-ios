//
//  HeadlineSummary.swift
//  newsum
//
//  Created by Li Li on 4/20/25.
//

import Foundation

struct HeadlineSummary: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: String
    let imageUrl: String?
    let summary: String
    let publishedAt: Date
    let summaryGeneratedAt: Date?
    let sourceName: String
    let sourceUrl: String

    enum CodingKeys: String, CodingKey {
        case title, description, url, summary
        case imageUrl = "image_url"
        case publishedAt = "published_at"
        case summaryGeneratedAt = "summary_generated_at"
        case sourceName = "source_name"
        case sourceUrl = "source_url"
    }
    
    init(
            title: String,
            description: String,
            url: String,
            imageUrl: String? = nil,
            summary: String,
            publishedAt: Date,
            summaryGeneratedAt: Date? = nil,
            sourceName: String,
            sourceUrl: String
        ) {
            self.title = title
            self.description = description
            self.url = url
            self.imageUrl = imageUrl
            self.summary = summary
            self.publishedAt = publishedAt
            self.summaryGeneratedAt = summaryGeneratedAt
            self.sourceName = sourceName
            self.sourceUrl = sourceUrl
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        url = try container.decode(String.self, forKey: .url)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        summary = try container.decode(String.self, forKey: .summary)
        sourceName = try container.decode(String.self, forKey: .sourceName)
        sourceUrl = try container.decode(String.self, forKey: .sourceUrl)

        // decode publishedAt using default ISO8601
        let publishedAtString = try container.decode(String.self, forKey: .publishedAt)
        if let publishedDate = ISO8601DateFormatter().date(from: publishedAtString) {
            publishedAt = publishedDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .publishedAt, in: container, debugDescription: "Invalid date format for publishedAt")
        }

        // decode summaryGeneratedAt, allow null
        if let summaryDateString = try? container.decodeIfPresent(String.self, forKey: .summaryGeneratedAt),
           let summaryDate = ISO8601DateFormatter().date(from: summaryDateString) {
            summaryGeneratedAt = summaryDate
        } else {
            summaryGeneratedAt = nil
        }
    }
}

