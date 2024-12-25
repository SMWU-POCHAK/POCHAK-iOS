//
//  MemorySummary.swift
//  pochak
//
//  Created by Haru on 12/25/24.
//

import Foundation

// MARK: - MemorySummary
struct MemorySummary: Codable {
    let latestPost: MemoryPost
    let memberProfileImage: String
    let handle: String
    let loginMemberProfileImage: String
    let followedDate: String
    let followDay, pochakCount, bondedCount, pochakedCount: Int
    let firstPochaked, firstPochak, firstBonded: MemoryPost
    let followDate: String
}
