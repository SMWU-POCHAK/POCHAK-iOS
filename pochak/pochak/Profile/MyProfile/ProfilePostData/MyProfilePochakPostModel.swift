//
//  MyProfilePochakPostModel.swift
//  pochak
//
//  Created by Seo Cindy on 12/28/23.
//

struct MyProfileUserAndPochakedPostResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MyProfileUserAndPochakedPostModel
}

struct MyProfileUserAndPochakedPostModel : Codable {
    var handle: String?
    var profileImage: String?
    var name: String?
    var message: String?
    var totalPostNum: Int?
    var followerCount: Int?
    var followingCount: Int?
    var isFollow: Bool?
    var pageInfo : PageDataModel
    var postList : [PostDataModel]
}

struct PageDataModel : Codable {
    var lastPage : Bool?
    var totalPages : Int?
    var totalElements : Int?
    var size : Int?
}

struct PostDataModel : Codable {
    var postId : Int?
    var postImage : String?
}

