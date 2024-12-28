//
//  MemoryPost.swift
//  pochak
//
//  Created by Haru on 12/25/24.
//

import Foundation

// MARK: - MemoryPost
struct MemoryPost: Codable {
    let id: Int?
    let imageURL: String?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case id = "postId"
        case imageURL = "postImage"
        case date = "postDate"
    }
}

struct MonthSection {
    let yearMonth: String
    var posts: [MemoryPost]
}
