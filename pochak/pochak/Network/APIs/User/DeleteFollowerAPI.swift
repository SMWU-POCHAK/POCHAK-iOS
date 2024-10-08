//
//  DeleteFollowerAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum DeleteFollowerAPI {
    case deleteFollower(handle: String, request: DeleteFollowerRequest)
}

extension DeleteFollowerAPI: BaseAPI {
    
    typealias Response = DeleteFollowerResponse
    
    var method: HTTPMethod {
        switch self {
        case .deleteFollower: return .delete
        }
    }
    
    var path: String {
        switch self {
        case .deleteFollower(let handle, _): return "/v2/members/\(handle)/follower"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .deleteFollower(_, let request): return .query(request)
        }
    }
}
