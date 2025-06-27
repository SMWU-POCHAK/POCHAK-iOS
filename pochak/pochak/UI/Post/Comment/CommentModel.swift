//
//  CommentModel.swift
//  pochak
//
//  Created by Suyeon Hwang on 6/27/25.
//

struct CommentModel {
    let loginMemberProfileiimage: String
    var commentDataModelList: [CommentDataModel]
    var commentPageModel: PageModel
}

struct CommentDataModel {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
    var childCommentPageModel: PageModel  // 대댓글을 추가로 페이징 조회했을 때 변경하기 위해서
    var childCommentCnt: Int
    var childCommentModelList: [ChildCommentModel]  // 대댓글을 추가로 페이징 조회했을 때 변경하기 위해서
}

struct PageModel {
    var isLastPage: Bool
    var isFetchingFirstPage: Bool
    var currentFetchingPage: Int
}

struct ChildCommentModel {
    let commentId: Int
    let profileImage: String
    let handle: String
    let createdDate: String
    let content: String
}
