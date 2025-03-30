//
//  PostDetailViewModel.swift
//  pochak
//
//  Created by Suyeon Hwang on 3/29/25.
//

import UIKit

class PostDetailViewModel {
    
    // MARK: - Properties
    
    private var postDetailData: PostDetailResponseResult? {
        didSet {
            postDetailDataDidChange?(postDetailData)
        }
    }
    
    private var likeResponseData: PostLikeResponse? {
        didSet {
            likeResponseDataDidChange?(likeResponseData)
        }
    }
    
    private var followResponseData: FollowResponse? {
        didSet {
            followResponseDataDidChange?(followResponseData)
        }
    }
    
    var postDetailDataDidChange: ((PostDetailResponseResult?) -> Void)?
    var likeResponseDataDidChange: ((PostLikeResponse?) -> Void)?
    var followResponseDataDidChange: ((FollowResponse?) -> Void)?
    
    // MARK: - Functions
    
    func fetchPostDetail(postId: Int, fromCurrentVC: UIViewController) {
        PostService.getPostDetail(postId: postId) { data, failed in
            guard let data = data else {
                switch failed {
                case .clientError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "게시글 조회에 실패하였습니다."), animated: true)
                }
                return
            }

            self.postDetailData = data.result
        }
    }
    
    func getPostDetailOwnerHandle() -> String? {
        return postDetailData?.ownerHandle
    }
    
    func getPostDetailTaggedUsers() -> [TaggedMember]? {
        return postDetailData?.tagList
    }
    
    /// 게시물 좋아요, 좋아요 취소를 요청하는 메소드입니다.
    /// - Parameters:
    ///   - postId: 게시물 아이디
    ///   - fromCurrentVC: 요청을 보내는 뷰컨트롤러
    func postLikeRequest(postId: Int, fromCurrentVC: UIViewController) {
        PostService.postLikePost(postId: postId) { data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "좋아요에 실패하였습니다."), animated: true)
                }
                return
            }
            self.likeResponseData = data
        }
    }
    
    /// 특정 유저 팔로우를 요청하는 메소드입니다.
    /// - Parameters:
    ///   - handle: 팔로우하고자 하는 유저의 핸들
    ///   - fromCurrentVC: 요청을 보내는 뷰컨트롤러
    func requestUserFollow(handle: String, fromCurrentVC: UIViewController) {
        UserService.postFollowRequest(handle: handle) { data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription),
                                  animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "팔로우 요청에 실패하였습니다."), animated: true)
                }
                return
            }
            self.followResponseData = data
        }
    }
}
