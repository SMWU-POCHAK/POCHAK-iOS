//
//  FollowAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/10/24.
//

import Foundation
import Alamofire

enum FollowAPI {
    case postFollowRequest(String)
}

extension FollowAPI: BaseAPI {
    
    typealias Response = FollowResponse
    
    var method: HTTPMethod {
        switch self {
        case .postFollowRequest: return .post
        }
    }
    
    var path: String {
        switch self {
        case .postFollowRequest(let handle): return "/v2/members/\(handle)/follow"
        }
    }
}
