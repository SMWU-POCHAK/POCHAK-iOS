//
//  FollowingRetrievalAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum FollowingRetrievalAPI {
    case getFollowings(handle: String, request: FollowListRequest)
}

extension FollowingRetrievalAPI: BaseAPI {
    
    typealias Response = FollowListResponse
        
    var method: HTTPMethod {
        switch self {
        case .getFollowings: return .get
        }
    }

    var path: String {
        switch self {
        case .getFollowings(let handle, _): return "/v2/members/\(handle)/following"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getFollowings(_, let request): return .query(request)
        }
    }
}
