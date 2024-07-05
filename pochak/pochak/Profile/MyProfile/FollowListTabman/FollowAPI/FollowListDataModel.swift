//
//  FollowDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 1/30/24.
//

struct FollowListDataResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: FollowListDataModel
}

struct FollowListDataModel : Codable {
    var pageInfo : PageDataModel
    var memberList : [MemberListDataModel]
}

struct MemberListDataModel: Codable {
    var profileImage: String?
    var handle: String?
    var name: String?
    var isFollow: Bool?
}
