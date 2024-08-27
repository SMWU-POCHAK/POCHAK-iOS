//
//  CommentDeleteResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

struct CommentDeleteResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
