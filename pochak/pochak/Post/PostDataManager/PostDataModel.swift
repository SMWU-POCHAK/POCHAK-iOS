//
//  PostDataResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/10/23.
//

// MARK: - Post Detail

struct PostDataResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PostDataResponseResult
}

struct PostDataResponseResult: Codable {
    let ownerHandle: String
    let ownerProfileImage: String
    let taggedMemberHandle: [String]
    let isFollow: Bool?  // 현재 로그인한 유저가 게시자라면 null이 됨
    let postImage: String
    let isLike: Bool
    let likeCount: Int
    let caption: String
    let recentComment: RecentComment?
}

struct RecentComment: Codable {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
}

// MARK: - Post Delete

struct PostDeleteResponse: Codable {
    let isSuccess : Bool
    let code : String
    let message : String
}

// MARK: - Post Report

struct PostReportResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
