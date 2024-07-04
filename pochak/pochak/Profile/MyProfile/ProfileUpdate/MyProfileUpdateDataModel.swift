//
//  MyProfileUpdateDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//

struct MyProfileUpdateResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MyProfileUpdateDataModel
}

struct MyProfileUpdateDataModel : Codable {
    var name : String?
    var handle : String?
    var message : String?
    var profileImage : String?
}
