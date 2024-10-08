//
//  CheckDuplicateHandleAPI.swift
//  pochak
//
//  Created by Seo Cindy on 10/1/24.
//

import Foundation
import Alamofire

enum CheckDuplicateHandleAPI {
    case checkDuplicateHandle(CheckDuplicateHandleRequest)
}

extension CheckDuplicateHandleAPI: BaseAPI {
    
    typealias Response = CheckDuplicateHandleResponse
        
    var method: HTTPMethod {
        switch self {
        case .checkDuplicateHandle: return .get
        }
    }

    var path: String {
        switch self {
        case .checkDuplicateHandle: return "/v2/members/duplicate"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .checkDuplicateHandle(let request): return .query(request)
        }
    }
}
