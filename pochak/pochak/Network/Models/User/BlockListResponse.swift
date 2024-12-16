//
//  BlockListResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct BlockListResponse : Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result : BlockListResult
}

struct BlockListResult : Codable {
    let pageInfo: BlockListPageInfo
    let blockList: [BlockList]
}

struct BlockListPageInfo : Codable {
    let lastPage : Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct BlockList : Codable {
    let profileImage: String
    let handle: String
    let name: String
}
