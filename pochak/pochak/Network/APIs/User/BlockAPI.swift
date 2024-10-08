//
//  BlockAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum BlockAPI {
    case blockUser(String)
}

extension BlockAPI: BaseAPI {
    
    typealias Response = BlockResponse
    
    var method: HTTPMethod {
        switch self {
        case .blockUser: return .post
        }
    }
    
    var path: String {
        switch self {
        case .blockUser(let handle): return "/v2/members/\(handle)/block"
        }
    }
}
