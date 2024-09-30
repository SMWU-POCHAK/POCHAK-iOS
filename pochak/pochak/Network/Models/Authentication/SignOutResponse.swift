//
//  SignOutResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct SignOutResponse : Codable {
    var isSuccess: Bool
    var code: String
    var message: String
}