//
//  PochakPostRetrievalResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct PochakPostRetrievalResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PochakPostRetrievalResult
}

struct PochakPostRetrievalResult : Codable {
    var pageInfo : ProfilePageInfo
    var postList : [ProfilePostList]
}
