//
//  ProfileRetrievalResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct ProfileRetrievalResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ProfileRetrievalResult
}

struct ProfileRetrievalResult : Codable {
    var handle: String?
    var profileImage: String?
    var name: String?
    var message: String?
    var totalPostNum: Int?
    var followerCount: Int?
    var followingCount: Int?
    var isFollow: Bool?
    var pageInfo : ProfilePageInfo
    var postList : [ProfilePostList]
    var isBonded: Bool?
    
    enum CodingKeys: String, CodingKey {
        case handle
        case profileImage
        case name
        case message
        case totalPostNum
        case followerCount
        case followingCount
        case isFollow
        case pageInfo
        case postList
        case isBonded = "isF4F"
    }
}

struct ProfilePageInfo : Codable {
    var lastPage : Bool
    var totalPages : Int
    var totalElements : Int
    var size : Int
}

struct ProfilePostList : Codable {
    var postId : Int
    var postImage : String
}
