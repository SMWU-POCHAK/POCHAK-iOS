//
//  UploadDataModel.swift
//  pochak
//
//  Created by 장나리 on 11/23/23.
//

struct UploadDataResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: UploadResult
}

struct UploadResult: Codable {
    let taggedUserHandles: [String]
    let postOwnerHandle: String
    let isFollow: Bool
    let postImageUrl: String
    let numOfHeart: Int
    let caption: String
}

struct UploadDataRequest:Codable{
    var caption: String
    var taggedMemberHandleList: [String]
}

