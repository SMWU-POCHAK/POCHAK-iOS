//
//  MemorySummary.swift
//  pochak
//
//  Created by Haru on 12/25/24.
//

import Foundation

// MARK: - MemorySummary
struct MemorySummary: Codable {
    let memberProfileImage: String
    let handle: String
    let loginMemberProfileImage: String
    let followDay: Int?
    let pochakCount, bondedCount, pochakedCount: Int
    let memories: [String: MemoryPost]
    let timeLine: [String: TimeLine]
    let bondedDate: String?
    
    enum CodingKeys: String, CodingKey {
        case memberProfileImage
        case handle
        case loginMemberProfileImage
        case followDay
        case pochakCount, bondedCount, pochakedCount
        case memories
        case timeLine
        case bondedDate = "f4fDate"
    }
}

struct TimeLine: Codable {
    let memoriesTypeString: String
    let postOwnerHandle: String?
    
    enum CodingKeys: String, CodingKey {
        case memoriesTypeString = "memoriesType"
        case postOwnerHandle
    }
    
    var timeLineMemoryType: TimeLineMemoryType {
        return TimeLineMemoryType(rawValue: memoriesTypeString) ?? .unknown
    }
}

enum TimeLineMemoryType: String, Codable {
    case latestPost = "LatestPost"
    case firstBonded = "FirstBonded"
    case firstPochak = "FirstPochak"
    case firstPochaked = "FirstPochaked"
    case followed = "Followed"
    case follow = "Follow"
    case unknown // 미정의된 타입 처리
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = TimeLineMemoryType(rawValue: rawValue) ?? .unknown
    }
}
