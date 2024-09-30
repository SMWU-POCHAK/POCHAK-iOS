//
//  FollowerRetrievalAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum FollowerRetrievalAPI {
    case getFollowers(handle: String, request: FollowListRequest)
}

extension FollowerRetrievalAPI: BaseAPI {
    
    typealias Response = FollowListResponse
        
    var method: HTTPMethod {
        switch self {
        case .getFollowers: return .get
        }
    }

    var path: String {
        switch self {
        case .getFollowers(let handle, _): return "/v2/members/\(handle)/follower"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getFollowers(_, let request): return .query(request)
        }
    }
}
