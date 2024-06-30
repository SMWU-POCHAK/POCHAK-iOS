//
//  GetAccessToken.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import Foundation

class GetToken {
    
    static func getAccessToken() -> String {
        guard let keyChainAccessToken = (try? KeychainManager.load(account: "accessToken")) else {return ""}
        return "Bearer " + keyChainAccessToken
    }
    
    static func getRefreshToken() -> String {
        guard let keyChainRefreshToken = (try? KeychainManager.load(account: "refreshToken")) else {return ""}
        return "Bearer " + keyChainRefreshToken
    }
}
