//
//  ProfileRetrievalAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum ProfileRetrievalAPI {
    case getProfile(handle: String, request: ProfileRetrievalRequest)
}

extension ProfileRetrievalAPI: BaseAPI {
    
    typealias Response = ProfileRetrievalResponse
        
    var method: HTTPMethod {
        switch self {
        case .getProfile: return .get
        }
    }

    var path: String {
        switch self {
        case .getProfile(let handle, _): return "/v2/members/\(handle)"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getProfile(_, let request): return .query(request)
        }
    }
}

