//
//  CameraAPI.swift
//  pochak
//
//  Created by 장나리 on 9/2/24.
//

import Foundation
import Alamofire

enum CameraAPI {
    case postUpload(CameraUploadRequest)
}

extension CameraAPI: BaseAPI {
    typealias Response = CameraUploadResponse
    
    var method: HTTPMethod {
        switch self {
        case .postUpload: return .post
        }
    }

    var path: String {
        switch self {
        case .postUpload: return "/v2/posts"
        }
    }

    var parameters: RequestParams? {
        switch self {
        case .postUpload(let request): return .query(request)
        }
    }
}
