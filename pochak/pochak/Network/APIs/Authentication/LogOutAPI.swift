//
//  LogOutAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum LogOutAPI {
    case logOut()
}

extension LogOutAPI: BaseAPI {
    
    typealias Response = LogOutResponse
        
    var method: HTTPMethod {
        switch self {
        case .logOut: return .get
        }
    }

    var path: String {
        switch self {
        case .logOut(): return "/v2/logout"
        }
    }
}
