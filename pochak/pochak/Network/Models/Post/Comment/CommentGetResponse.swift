//
//  CommentGetResponse.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/19/24.
//

struct CommentGetResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: CommentDataResult
}

struct CommentDataResult: Codable {
    let parentCommentPageInfo: ParentCommentPageInfo?
    var parentCommentList: [ParentCommentData]  // 대댓글을 추가로 페이징 조회했을 때 변경하기 위해서
    let loginMemberProfileImage: String
}

struct ParentCommentPageInfo: Codable {
    let lastPage: Bool
    let totalPages: Int  // 부모 댓글 페이징 정보 : 총 페이지 수
    let totalElements: Int  // 부모 댓글 페이징 정보 : 총 부모 댓글의 수
    let size: Int  // 부모 댓글 페이징 정보 : 페이징 사이즈
}

struct ParentCommentData: Codable {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
    var childCommentPageInfo: ChildCommentPageInfo  // 대댓글을 추가로 페이징 조회했을 때 변경하기 위해서
    var childCommentList: [ChildCommentData]  // 대댓글을 추가로 페이징 조회했을 때 변경하기 위해서
}

struct ChildCommentPageInfo: Codable {
    var lastPage: Bool  // 대댓글을 추가로 페이징 조회했을 때 변경하기 위해서
    let totalPages: Int
    let totalElements: Int
    let size: Int
}

struct ChildCommentData: Codable {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
}
