//
//  PreviewDataModel.swift
//  pochak
//
//  Created by 장나리 on 7/3/24.
//

import Foundation

struct PreviewAlarmResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PreviewAlarmResult
}

// MARK: - Result DTO
struct PreviewAlarmResult: Codable {
    let ownerId: Int
    let ownerHandle: String
    let ownerProfileImage: String
    let tagList: [PreviewTagList]
    let postImage: String
}

// MARK: - Tag DTO
struct PreviewTagList: Codable {
    let memberId: Int
    let profileImage: String
    let handle: String
    let name: String
}
