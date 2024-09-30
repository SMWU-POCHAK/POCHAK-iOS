//
//  UICommentModel.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

/// UI에 보여주기 위해 쓸 데이터 구조체
struct UICommentData {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
    let isParent: Bool
    let parentId: Int?
}
