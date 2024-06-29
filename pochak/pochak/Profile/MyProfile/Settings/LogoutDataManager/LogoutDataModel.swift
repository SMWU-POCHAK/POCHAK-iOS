//
//  LogoutDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//

struct LogoutDataResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: LogoutDataModel
}

struct LogoutDataModel : Codable {
    var isSuccess: Bool
    var code: Int
    var message: String
}
