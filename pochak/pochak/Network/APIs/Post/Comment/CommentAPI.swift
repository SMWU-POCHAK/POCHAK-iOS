//
//  CommentAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/19/24.
//

import Foundation
import Alamofire

enum CommentAPI {
    case getComments(postId: Int, request: CommentGetRequest)
}

extension CommentAPI: BaseAPI {
    
    typealias Response = CommentGetResponse
        
    var method: HTTPMethod {
        switch self {
        case .getComments: return .get
        }
    }

    var path: String {
        switch self {
        case .getComments(let postId, _): return "/v2/posts/\(postId)/comments"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getComments(_, let request): return .query(request)
        }
    }
}
