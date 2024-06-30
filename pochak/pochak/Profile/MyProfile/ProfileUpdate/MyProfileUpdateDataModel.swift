//
//  MyProfileUpdateDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//

struct MyProfileUpdateResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: MyProfileUpdateDataModel
}

struct MyProfileUpdateDataModel : Codable {
    var profileImgUrl : String?
    var name : String?
    var handle : String?
    var message : String?
}
