//
//  ChildCommentGetResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/20/24.
//

struct ChildCommentGetResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    var result: ChildCommentDataResult
}

struct ChildCommentDataResult: Codable {
    let commentId: Int  // 부모 댓글 아이디
    let profileImage: String  // 부모 댓글 작성자 프로필 사진
    let handle: String  // 부모 댓글 작성자 아이디
    let createdDate: String  // 부모 댓글 작성 시간
    let content: String  // 부모 댓글 내용
    var childCommentPageInfo: ChildCommentPageInfo
    let childCommentList: [ChildCommentData]
}
