//
//  ProfileAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/18/24.
//

import Foundation
import Alamofire

enum ProfileAPI {
    case getHomePost(HomeRequest)
}

extension ProfileAPI: BaseAPI {
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

    var parameters: RequestParams {
        switch self {
        case .getHomePost(let request): return .query(request)
        }
    }
}
