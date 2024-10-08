//
//  SignUpRequest.swift
//  pochak
//
//  Created by Seo Cindy on 10/1/24.
//

import Foundation

struct SignUpRequest : Codable {
    let name: String
    let email: String
    let handle: String
    let message: String
    let socialId: String
    let socialType: String
}
