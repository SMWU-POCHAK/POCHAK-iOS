//
//  AppleLoginDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 7/1/24.
//

import Foundation

struct AppleLoginResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: AppleLoginModel
}

struct AppleLoginModel: Codable {
    let socialId: String?
    let name: String?
    let email: String?
    let handle: String?
    let socialType: String?
    let accessToken: String?
    let refreshToken: String?
    let isNewMember: Bool?
}
