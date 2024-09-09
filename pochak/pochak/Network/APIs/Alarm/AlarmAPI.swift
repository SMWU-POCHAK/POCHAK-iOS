//
//  AlarmAPI.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation

enum AlarmAPI {
    case getAlarmList(AlarmRequest)
}

extension AlarmAPI: BaseAPI {
    var method: HTTPMethod {
        switch self {
        case .getAlarmList: return .get
        }
    }

    var path: String {
        switch self {
        case .getAlarmList: return "/v2/alarms"
        }
    }

    var parameters: RequestParams {
        switch self {
        case .getAlarmList(let request): return .query(request)
        }
    }
}
