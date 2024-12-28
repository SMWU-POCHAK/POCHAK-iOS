//
//  AuthenticationCredential.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Foundation
import Alamofire

struct MyAuthenticationCredential: AuthenticationCredential, Codable {
    let accessToken: String
    let refreshToken: String
    let expiredAt: Date
    var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 10) > expiredAt }
}
