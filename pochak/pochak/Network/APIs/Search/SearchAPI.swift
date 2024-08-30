//
//  SearchAPI.swift
//  pochak
//
//  Created by 장나리 on 8/25/24.
//

import Foundation
import Alamofire

enum SearchAPI {
    case getSearch(SearchRequest)
}

extension SearchAPI: BaseAPI {
    typealias Response = SearchResponse
    
    var method: HTTPMethod {
        switch self {
        case .getSearch: return .get
        }
    }

    var path: String {
        switch self {
        case .getSearch: return "/v2/members/search"
        }
    }

    var parameters: RequestParams {
        switch self {
        case .getSearch(let request): return .query(request)
        }
    }
}
