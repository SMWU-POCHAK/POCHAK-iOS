//
//  ProfileViewResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/18/24.
//

import Foundation

struct ProfileViewResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ProfileData
}

struct ProfileData : Codable {
    var handle: String?
    var profileImage: String?
    var name: String?
    var message: String?
    var totalPostNum: Int?
    var followerCount: Int?
    var followingCount: Int?
    var isFollow: Bool?
    var pageInfo : ProfilePageData
    var postList : [ProfilePostData]
}

struct ProfilePageData : Codable {
    var lastPage : Bool
    var totalPages : Int
    var totalElements : Int
    var size : Int
}

struct ProfilePostData : Codable {
    var postId : Int
    var postImage : String
}
