//
//  UnblockResponse.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct UnblockResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}