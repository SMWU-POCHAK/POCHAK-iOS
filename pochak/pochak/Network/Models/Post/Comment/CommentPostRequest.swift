//
//  CommentPostRequest.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

struct CommentPostRequest: Codable {
    let content: String
    let parentCommentId: Int?
}
