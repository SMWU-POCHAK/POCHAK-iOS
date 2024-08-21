//
//  ExploreTabAPI.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation
import Alamofire

enum ExploreTabAPI {
    case getExploreTab(ExploreTabRequest)
}

extension ExploreTabAPI: BaseAPI {
    typealias Response = ExploreTabResponse
    
    var method: HTTPMethod {
        switch self {
        case .getExploreTab: return .get
        }
    }

    var path: String {
        switch self {
        case .getExploreTab: return "/v2/posts/search"
        }
    }

    var parameters: RequestParams {
        switch self {
        case .getExploreTab(let request): return .query(request)
        }
    }
}
