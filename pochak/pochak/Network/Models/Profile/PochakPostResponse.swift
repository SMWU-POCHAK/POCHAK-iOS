//
//  PochakPostResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/18/24.
//

import Foundation

struct PochakPostResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PochakPostData
}

struct PochakPostData : Codable {
    var pageInfo : ProfilePageData
    var postList : [ProfilePostData]
}
