//
//  PostAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

import Foundation
import Alamofire

enum PostAPI {
    case getPostDetail(_ id: Int)
}

extension PostAPI: BaseAPI {
    
    typealias Response = PostDetailResponse
        
    var method: HTTPMethod {
        switch self {
        case .getPostDetail: return .get
        }
    }

    var path: String {
        switch self {
        case .getPostDetail(let id): return "/v2/posts/\(id)"
        }
    }
}
