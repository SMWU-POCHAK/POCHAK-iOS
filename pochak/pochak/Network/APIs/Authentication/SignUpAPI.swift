//
//  SignUpAPI.swift
//  pochak
//
//  Created by Seo Cindy on 10/1/24.
//

import Foundation
import Alamofire

enum SignUpAPI {
    case signUp(SignUpRequest)
}

extension SignUpAPI: BaseAPI {
    
    typealias Response = SignUpResponse
    
    var method: HTTPMethod {
        switch self {
        case .signUp: return .post
        }
    }
    
    var path: String {
        switch self {
        case .signUp: return "/v2/signup"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .signUp(let request): return .query(request)
        }
    }
}
