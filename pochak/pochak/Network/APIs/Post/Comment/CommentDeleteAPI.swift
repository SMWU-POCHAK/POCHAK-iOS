//
//  CommentDeleteAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

import Foundation
import Alamofire

enum CommentDeleteAPI {
    case deleteComment(postId: Int, commentId: Int)
}

extension CommentDeleteAPI: BaseAPI {
    
    typealias Response = CommentDeleteResponse
        
    var method: HTTPMethod {
        switch self {
        case .deleteComment: return .delete
        }
    }

    var path: String {
        switch self {
        case .deleteComment(let postId, _): return "/v2/posts/\(postId)/comments"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .deleteComment(_, let commentId): return .query(["commentId" : commentId])
        }
    }
}
