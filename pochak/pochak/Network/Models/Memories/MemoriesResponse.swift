//
//  MemoriesResponse.swift
//  pochak
//
//  Created by Haru on 10/14/24.
//

import Foundation

struct CommonResponse<T: Codable>: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T
}

// MARK: - Memories
struct MemorySummary: Codable {
    let handle: String
    let loginMemberProfileImage, memberProfileImage: String
    let followDate, followedDate: String
    let followDay, pochakCount, bondedCount, pochakedCount: Int
    let firstPochaked, firstPochak, firstBonded, latestPost: FirstBonded
}

// MARK: - FirstBonded
struct FirstBonded: Codable {
    let postID: Int
    let postImage: String
    let postDate: String
    
    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case postImage, postDate
    }
}

// MARK: - MemoryList
struct MemoryList: Codable {
    let pageInfo: PageInfo
    let pochakedPostList: [PochakedPost]
    
    enum CodingKeys: String, CodingKey {
        case pageInfo = "pageInfo"
        case pochakedPostList = "postList"
    }
}


// MARK: - PochakedPost
struct PochakedPost: Codable {
    let postID: Int
    let postImage: String

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case postImage
    }
}
