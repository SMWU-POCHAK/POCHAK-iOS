//
//  SignOutAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

enum SignOutAPI {
    case signOut()
}

extension SignOutAPI: BaseAPI {
    
    typealias Response = SignOutResponse
        
    var method: HTTPMethod {
        switch self {
        case .signOut: return .delete
        }
    }

    var path: String {
        switch self {
        case .signOut(): return "/v2/signout"
        }
    }
}
