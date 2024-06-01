import Foundation
import UIKit

// MARK: - Welcome
struct STVWelcome: Codable {
    let kind, etag: String
    let items: [STVItem]
    let nextPageToken: String?
    let pageInfo: STVPageInfo
}

// MARK: - Item
struct STVItem: Codable {
    let kind, etag, id: String
    let snippet: STVSnippet
    let contentDetails: ContentDetails?
    let statistics: Statistics?
}

// MARK: - ContentDetails
struct ContentDetails: Codable {
    let duration, dimension, definition, caption: String
    let licensedContent: Bool
    let contentRating: ContentRating
    let projection: String
    let regionRestriction: RegionRestriction?
}

// MARK: - ContentRating
struct ContentRating: Codable {
}

// MARK: - RegionRestriction
struct RegionRestriction: Codable {
    let allowed: [String]?
    let blocked: [String]?
}


// MARK: - Snippet
struct STVSnippet: Codable {
    let publishedAt: Date
    let channelID, title: String
    let description: String?
    let thumbnails: STVThumbnails
    let channelTitle: String
    let tags: [String]?
    let categoryID, liveBroadcastContent: String
    let defaultLanguage: String?
    let localized: Localized
    let defaultAudioLanguage: String?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelID = "channelId"
        case title, description, thumbnails, channelTitle, tags
        case categoryID = "categoryId"
        case liveBroadcastContent, defaultLanguage, localized, defaultAudioLanguage
    }
}


// MARK: - Localized
struct Localized: Codable {
    let title, description: String
}

// MARK: - Thumbnails
struct STVThumbnails: Codable {
    let thumbnailsDefault, medium, high, standard: STVDefault
    let maxres: STVDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault = "default"
        case medium, high, standard, maxres
    }
}

// MARK: - Default
struct STVDefault: Codable {
    let url: String
    let width, height: Int
}

// MARK: - Statistics
struct Statistics: Codable {
    let viewCount, likeCount, favoriteCount, commentCount: String?
}

// MARK: - PageInfo
struct STVPageInfo: Codable {
    let totalResults, resultsPerPage: Int
}
