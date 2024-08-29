//
//  PostReportAPI.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

import Foundation
import Alamofire

enum PostReportAPI {
    case postReportPost(PostReportRequest)
}

extension PostReportAPI: BaseAPI {
    
    typealias Response = PostReportResponse
        
    var method: HTTPMethod {
        switch self {
        case .postReportPost: return .post
        }
    }

    var path: String {
        switch self {
        case .postReportPost(let request): return "/v1/reports"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .postReportPost(let request): return .body(request)
        }
    }
}
