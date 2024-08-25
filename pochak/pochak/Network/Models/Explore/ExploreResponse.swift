//
//  ExploreTabResponse.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation

struct ExploreResponse: Codable {
    let isSuccess : Bool
    let code: String
    let message: String
    let result: ExploreDataResult
}

struct ExploreDataResult: Codable {
    let pageInfo : ExploreDataPageInfo
    let postList : [ExploreDataPostList]
}

struct ExploreDataPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct ExploreDataPostList: Codable {
    let postId: Int
    let postImage: String
}
