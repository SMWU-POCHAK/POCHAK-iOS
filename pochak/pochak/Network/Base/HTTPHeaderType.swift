//
//  HTTPHeaderType.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation

enum HTTPHeaderType: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
}

enum ContentType: String {
    case json = "Application/json"
}
