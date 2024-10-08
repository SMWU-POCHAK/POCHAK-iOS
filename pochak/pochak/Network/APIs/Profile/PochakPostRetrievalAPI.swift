//
//  PochakPostRetrievalAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire


enum PochakPostRetrievalAPI {
    case getPochakPost(handle: String, request: ProfileRetrievalRequest)
}

extension PochakPostRetrievalAPI: BaseAPI {
    
    typealias Response = PochakPostRetrievalResponse
        
    var method: HTTPMethod {
        switch self {
        case .getPochakPost: return .get
        }
    }

    var path: String {
        switch self {
        case .getPochakPost(let handle, _): return "/v2/members/\(handle)/upload"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getPochakPost(_, let request): return .query(request)
        }
    }
}

