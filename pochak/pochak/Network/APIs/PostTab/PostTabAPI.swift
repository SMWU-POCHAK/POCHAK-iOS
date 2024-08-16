//
//  PostTabAPI.swift
//  pochak
//
//  Created by 장나리 on 8/16/24.
//

import Foundation
import Alamofire

enum PostTabAPI {
    case getPostTab(PostTabRequest)
}

extension PostTabAPI: BaseAPI {
    typealias Response = PostTabResponse
    
    var method: HTTPMethod {
        switch self {
        case .getPostTab: return .get
        }
    }

    var path: String {
        switch self {
        case .getPostTab: return "/v2/posts/search"
        }
    }

    var parameters: RequestParams {
        switch self {
        case .getPostTab(let request): return .query(request)
        }
    }
}
