//
//  NewsItem.swift
//  News API
//
//  Created by user on 10/31/21.
//

import UIKit

// MARK: - APIService
struct APIService: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let articleDescription: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}


class ArticleObject {
    var id = 0
    let sourceName: String
    let title: String
    let url: String
    let urlToImage: String?
    let publishedAt: String
    
    init(from article: Article) {
        sourceName = article.source.name
        title = article.title
        url = article.url
        urlToImage = article.urlToImage
        publishedAt = article.publishedAt
    }
}
