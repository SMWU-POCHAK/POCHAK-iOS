//
//  ExploreTabResponse.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation

struct ExploreTabResponse: Codable {
    let isSuccess : Bool
    let code: String
    let message: String
    let result: ExploreTabDataResult
}

struct ExploreTabDataResult: Codable {
    let pageInfo : ExploreTabDataPageInfo
    let postList : [ExploreTabDataPostList]
}

struct ExploreTabDataPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct ExploreTabDataPostList: Codable {
    let postId: Int
    let postImage: String
}
