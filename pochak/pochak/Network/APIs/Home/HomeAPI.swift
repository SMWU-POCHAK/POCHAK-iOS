//
//  HomeService.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation
import Alamofire

enum HomeAPI {
    case getHomePost(HomeRequest)
}

extension HomeAPI: BaseAPI {
    typealias Response = HomeResponse
    
    var method: HTTPMethod {
        switch self {
        case .getHomePost: return .get
        }
    }

    var path: String {
        switch self {
        case .getHomePost: return "/v2/posts"
        }
    }

    var parameters: RequestParams? {
        switch self {
        case .getHomePost(let request): return .query(request)
        }
    }
}
