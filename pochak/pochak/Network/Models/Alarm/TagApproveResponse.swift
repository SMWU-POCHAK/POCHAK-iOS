//
//  TagApproveResponse.swift
//  pochak
//
//  Created by 장나리 on 9/9/24.
//

import Foundation

struct TagApproveResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
