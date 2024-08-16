//
//  PostTabResponse.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation

struct PostTabResponse: Codable {
    let isSuccess : Bool
    let code: String
    let message: String
    let result: PostTabDataResult
}

struct PostTabDataResult: Codable {
    let pageInfo : PostTabDataPageInfo
    let postList : [PostTabDataPostList]
}

struct PostTabDataPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct PostTabDataPostList: Codable {
    let postId: Int
    let postImage: String
}
