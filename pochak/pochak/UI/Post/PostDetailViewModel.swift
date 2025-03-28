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
    
    var postDetailDataDidChange: ((PostDetailResponseResult?) -> Void)?
    
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
}
