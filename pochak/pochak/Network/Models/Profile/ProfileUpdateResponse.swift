//
//  ProfileUpdateResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct ProfileUpdateResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ProfileUpdateDataModel
}

struct ProfileUpdateDataModel : Codable {
    var name : String?
    var handle : String?
    var message : String?
    var profileImage : String?
}
