//
//  TagPreviewResponse.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation

struct TagPreviewResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PreviewAlarmResult
}

struct PreviewAlarmResult: Codable {
    let ownerId: Int
    let ownerHandle: String
    let ownerProfileImage: String
    let tagList: [PreviewTagList]
    let postImage: String
}

struct PreviewTagList: Codable {
    let memberId: Int
    let profileImage: String
    let handle: String
    let name: String
}
