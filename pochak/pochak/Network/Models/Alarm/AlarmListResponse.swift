//
//  AlarmListResponse.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation

struct AlarmListResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: AlarmResult
}

struct AlarmResult: Codable {
    let pageInfo: PageInfo
    let alarmList: [AlarmElementList]
}

struct PageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct AlarmElementList: Codable {
    let alarmId: Int
    let alarmType: AlarmType
    let isChecked: Bool
    let tagId: Int?
    let ownerId : Int?
    let ownerHandle: String?
    let ownerName: String?
    let ownerProfileImage: String?
    let postId: Int?
    let postImage: String?
    let memberId : Int?
    let memberHandle: String?
    let memberName: String?
    let memberProfileImage: String?
    let commentId: Int?
    let commentContent: String?
}
