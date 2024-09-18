//
//  SearchResponse.swift
//  pochak
//
//  Created by 장나리 on 8/25/24.
//

import Foundation

struct SearchResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SearchResult
}

struct SearchResult: Codable {
    let pageInfo: SearchPageInfo
    let memberList: [SearchMember]
}

struct SearchPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct SearchMember: Codable {
    let memberId: Int
    let profileImage: String
    let handle: String
    let name: String
    let isFollow: Bool?
}
