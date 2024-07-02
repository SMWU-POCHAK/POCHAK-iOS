//
//  TagDataModel.swift
//  pochak
//
//  Created by 장나리 on 12/27/23.
//

import Foundation

struct IdSearchResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: IdSearchResult
}

struct IdSearchResult: Codable {
    let pageInfo: IdSearchPageInfo
    let memberList: [IdSearchMember]
}

struct IdSearchPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct IdSearchMember: Codable {
    let memberId: Int
    let profileImage: String
    let handle: String
    let name: String
    let isFollow: Bool?
}
