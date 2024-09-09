//
//  TagApproveAPI.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation
import Alamofire

enum TagApproveAPI {
    case postTagApprove(tagId: Int, tagApproveRequest: TagApproveRequest)
}

extension TagApproveAPI: BaseAPI {
    typealias Response = TagApproveResponse

    var method: HTTPMethod {
        switch self {
        case .postTagApprove: return .post
        }
    }

    var path: String {
        switch self {
        case .postTagApprove(let tagId, _): return "/v2/tags/\(tagId)"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .postTagApprove(_, let tagApproveRequest): return .query(tagApproveRequest)
        }
    }
}
