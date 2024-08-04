//
//  RefreshTokenAPI.swift
//  pochak
//
//  Created by Seo Cindy on 7/5/24.
//

import Foundation
import Alamofire

class RequestInterceptor {

    static func getRequestInterceptor() -> AuthenticationInterceptor<MyAuthenticator> {
        // Get Token
        let accessToken = GetToken.getAccessToken()
        let refreshToken = GetToken.getRefreshToken()
        
        // Set Authenticator
        let authenticator = MyAuthenticator()
        let credential = MyAuthenticationCredential(accessToken: accessToken,
                                                    refreshToken: refreshToken,
                                                    expiredAt: Date(timeIntervalSinceNow: 60 * 30))
        let myAuthencitationInterceptor = AuthenticationInterceptor(authenticator: authenticator,
                                                                    credential: credential)
        return myAuthencitationInterceptor
    }
}
