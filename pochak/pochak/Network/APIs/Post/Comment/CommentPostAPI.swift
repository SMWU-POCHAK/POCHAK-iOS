//
//  CommentPostAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

import Foundation
import Alamofire

enum CommentPostAPI {
    case postNewComment(postId: Int, request: CommentPostRequest)
}

extension CommentPostAPI: BaseAPI {
    
    typealias Response = CommentPostResponse
        
    var method: HTTPMethod {
        switch self {
        case .postNewComment: return .post
        }
    }

    var path: String {
        switch self {
        case .postNewComment(let postId, _): return "/v2/posts/\(postId)/comments"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .postNewComment(_, let request): return .body(request)
        }
    }
}
