//
//  CommentDataModel.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/26/23.
//

// MARK: - 댓글 조회 Data Model

struct CommentDataResponse: Codable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
    let result: CommentDataResult?
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

// MARK: - 대댓글 조회 Data Model

struct ChildCommentDataResponse: Codable {
    let isSuccess: Bool?
    let code: String?
    let message: String?
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

// MARK: - 댓글 등록 Data Model (Response만 존재)

struct PostCommentResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}

// MARK: - 댓글 삭제 Data Model (Response만 있음)

struct DeleteCommentResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}

// MARK: - UI에 보여주기 위해 쓸 데이터 모델

struct UICommentData {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
    let isParent: Bool
    let parentId: Int?
}
