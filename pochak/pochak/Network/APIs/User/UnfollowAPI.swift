//
//  UnfollowAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum UnfollowAPI {
    case unfollowUser(handle: String, request: UnfollowRequest)
}

extension UnfollowAPI: BaseAPI {
    
    typealias Response = FollowResponse
        
    var method: HTTPMethod {
        switch self {
        case .unfollowUser: return .delete
        }
    }

    var path: String {
        switch self {
        case .unfollowUser(let handle, _): return "/v2/members/\(handle)/follower"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .unfollowUser(_, let request): return .query(request)
        }
    }
}
