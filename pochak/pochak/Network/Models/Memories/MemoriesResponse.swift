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

struct SummaryGalleryItem {
    let type: MemoryType
    let post: MemoryPost
}

struct TimelineItem {
    let date: String
    let icon: TimelineIcon
    let message: String
}

enum TimelineIcon {
    case profile
    case camera
}
