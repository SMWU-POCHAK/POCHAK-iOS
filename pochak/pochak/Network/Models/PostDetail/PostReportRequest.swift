//
//  PostReportRequest.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/9/24.
//

import Foundation

struct PostReportRequest: Codable {
    let postId: Int
    let reportType: String
}
