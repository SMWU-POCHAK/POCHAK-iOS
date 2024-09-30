//
//  ExploreTabAPI.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation
import Alamofire

enum ExploreAPI {
    case getExplore(ExploreRequest)
}

extension ExploreAPI: BaseAPI {
    typealias Response = ExploreResponse
    
    var method: HTTPMethod {
        switch self {
        case .getExplore: return .get
        }
    }

    var path: String {
        switch self {
        case .getExplore: return "/v2/posts/search"
        }
    }

    var parameters: RequestParams? {
        switch self {
        case .getExplore(let request): return .query(request)
        }
    }
}
