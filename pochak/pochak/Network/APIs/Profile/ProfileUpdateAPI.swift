//
//  ProfileUpdateAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation


enum ProfileUpdateAPI {
    case updateProfile(handle: String, request: ProfileUpdateRequest)
}

extension ProfileUpdateAPI: BaseAPI {
    
    typealias Response = ProfileUpdateResponse
        
    var method: HTTPMethod {
        switch self {
        case .updateProfile: return .post
        }
    }

    var path: String {
        switch self {
        case .updateProfile(let handle, _): return "/v2/members/\(handle)"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .updateProfile(_, let request): return .body(request)
        }
    }
}
