//
//  BlockListAPI.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation
import Alamofire

enum BlockListAPI {
    case getBlockUserList(handle: String, request: BlockListRequest)
}

extension BlockListAPI: BaseAPI {
    
    typealias Response = BlockListResponse
    
    var method: HTTPMethod {
        switch self {
        case .getBlockUserList: return .get
        }
    }
    
    var path: String {
        switch self {
        case .getBlockUserList(let handle, _): return "/v2/members/\(handle)/block"
        }
    }
    
    var parameters: RequestParams? {
        switch self {
        case .getBlockUserList(_, let request): return .query(request)
        }
    }
}
