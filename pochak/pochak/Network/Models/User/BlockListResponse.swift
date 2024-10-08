//
//  BlockListResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct BlockListResponse : Codable {
    var isSuccess: Bool
    var code: String
    var message: String
    var result : BlockListResult
}

struct BlockListResult : Codable {
    var pageInfo: BlockListPageInfo
    var blockList: [BlockList]
}

struct BlockListPageInfo : Codable {
    var lastPage : Bool
    var totalPages: Int
    var totalElements: Int
    var size: Int
}

struct BlockList : Codable {
    var profileImage: String
    var handle: String
    var name: String
}
