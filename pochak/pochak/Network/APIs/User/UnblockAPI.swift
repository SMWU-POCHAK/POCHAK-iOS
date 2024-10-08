//
//  UnblockAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum UnblockAPI {
    case unblockUser(handle: String, request: UnblockRequest)
}

extension UnblockAPI: BaseAPI {
    
    typealias Response = UnblockResponse
    
    var method: HTTPMethod {
        switch self {
        case .unblockUser: return .delete
        }
    }
    
    var path: String {
        switch self {
        case .unblockUser(let handle, _): return "/v2/members/\(handle)/block"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .unblockUser(_, let request): return .query(request)
        }
    }
}
