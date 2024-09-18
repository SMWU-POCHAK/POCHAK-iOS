//
//  PostLikeAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/9/24.
//

import Foundation
import Alamofire

enum PostLikeAPI {
    case postLikePost(Int)
}

extension PostLikeAPI: BaseAPI  {
    typealias Response = PostLikeResponse
        
    var method: HTTPMethod {
        switch self {
        case .postLikePost: return .post
        }
    }

    var path: String {
        switch self {
        case .postLikePost(let postId): return "/v2/posts/\(postId)/like"
        }
    }
}
