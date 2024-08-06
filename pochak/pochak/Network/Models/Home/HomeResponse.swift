//
//  HomeResponse.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation

struct HomeResponse: Codable {
    let isSuccess : Bool
    let code: String
    let message: String
    let result: HomeDataResult
}

struct HomeDataResult: Codable {
    let pageInfo : HomeDataPageInfo
    let postList : [HomeDataPostList]
}

struct HomeDataPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct HomeDataPostList: Codable {
    let postId: Int
    let postImage: String
}
