//
//  CheckDuplicateHandleResponse.swift
//  pochak
//
//  Created by Seo Cindy on 10/1/24.
//

import Foundation

struct CheckDuplicateHandleResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
