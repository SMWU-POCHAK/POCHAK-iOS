//
//  ChildCommentAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

import Foundation
import Alamofire

enum ChildCommentAPI {
    case getChildComments(postId: Int, commentId: Int, page: Int)
}

extension ChildCommentAPI: BaseAPI {
    
    typealias Response = ChildCommentGetResponse
        
    var method: HTTPMethod {
        switch self {
        case .getChildComments: return .get
        }
    }

    var path: String {
        switch self {
        case .getChildComments(let postId, let commentId, _): return "/v2/posts/\(postId)/comments/\(commentId)"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getChildComments(_, _, let page): return .query(["page": page])
        }
    }
}

