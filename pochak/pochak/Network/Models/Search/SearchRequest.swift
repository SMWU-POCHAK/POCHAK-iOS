//
//  SearchRequest.swift
//  pochak
//
//  Created by 장나리 on 8/25/24.
//

import Foundation

struct SearchRequest: Encodable {
    let page: Int
    let keyword: String
}
