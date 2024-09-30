//
//  PostDeleteAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

import Alamofire

enum PostDeleteAPI {
    case deletePostDetail(_ id: Int)
}

extension PostDeleteAPI: BaseAPI  {
    typealias Response = PostDeleteResponse
        
    var method: HTTPMethod {
        switch self {
        case .deletePostDetail: return .delete
        }
    }

    var path: String {
        switch self {
        case .deletePostDetail(let id): return "/v2/posts/\(id)"
        }
    }
}
