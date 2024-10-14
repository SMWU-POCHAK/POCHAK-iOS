//
//  FollowListResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct FollowListResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: FollowListResult
}

struct FollowListResult: Codable {
    var pageInfo: FollowListPageInfo
    var memberList: [MemberListData]
}

struct FollowListPageInfo: Codable {
    var lastPage : Bool
    var totalPages : Int
    var totalElements : Int
    var size : Int
}

struct MemberListData: Codable {
    var memberId: Int
    var profileImage: String
    var handle: String
    var name: String
    var isFollow: Bool?
}
