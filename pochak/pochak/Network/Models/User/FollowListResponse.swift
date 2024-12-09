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
    let pageInfo: FollowListPageInfo
    let memberList: [MemberListData]
}

struct FollowListPageInfo: Codable {
    let lastPage : Bool
    let totalPages : Int
    let totalElements : Int
    let size : Int
}

struct MemberListData: Codable {
    let memberId: Int
    let profileImage: String
    let handle: String
    let name: String
    let isFollow: Bool?
}
