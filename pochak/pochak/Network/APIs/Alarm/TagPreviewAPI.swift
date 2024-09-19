//
//  TagPreviewAPI.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation
import Alamofire

enum TagPreviewAPI {
    case getTagPreview(Int)
}

extension TagPreviewAPI: BaseAPI {
    typealias Response = TagPreviewResponse

    var method: HTTPMethod {
        switch self {
        case .getTagPreview: return .get
        }
    }

    var path: String {
        switch self {
        case .getTagPreview(let alarmId): return "/v2/alarms/\(alarmId)"
        }
    }
}
