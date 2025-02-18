//
//  ProfileViewModel.swift
//  pochak
//
//  Created by Suyeon Hwang on 2/16/25.
//

import UIKit

class ProfileViewModel {
    
    // MARK: - Properties
    
    private var profileData: ProfileRetrievalResult? {
        didSet {
            profileDataDidChange?(profileData)
        }
    }
    
    private var pochakPostData: PochakPostRetrievalResult? {
        didSet {
            pochakPostDataDidChange?(pochakPostData)
        }
    }
    
    var profileDataDidChange: ((ProfileRetrievalResult?) -> Void)?
    var pochakPostDataDidChange: ((PochakPostRetrievalResult?) -> Void)?
    
    // MARK: - Functions
    
    /// ProfileService를 통해 handle 멤버의 프로필을 조회하는 메소드입니다. (프로필 정보, 포착된 게시글)
    /// - Parameters:
    ///   - handle: 프로필을 조회하고자 하는 멤버의 handle
    ///   - request: 요청 데이터를 담은 ProfileRetrievalRequest
    ///   - fromCurrentVC: 현재 해당 요청을 보내는 뷰컨트롤러
    func fetchMyProfile(handle: String, request: ProfileRetrievalRequest, fromCurrentVC: UIViewController) {
        ProfileService.getProfile(handle: handle, request: request) { data, failed in
            guard let data = data else {
                switch failed {
                case .clientError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "유효하지 않은 멤버의 handle입니다."), animated: true)
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            self.profileData = data.result
        }
    }
    
    /// ProfileService를 통해 handle 멤버가 포착한 게시글을 조회하는 메소드입니다.
    /// - Parameters:
    ///   - handle: 조회하려는 멤버의 handle
    ///   - request: 요청 데이터를 담은 ProfileRetrievalRequest
    ///   - fromCurrentVC: 현재 해당 요청을 보내는 뷰컨트롤러
    func fetchPochakPosts(handle: String, request: ProfileRetrievalRequest, fromCurrentVC: UIViewController) {
        ProfileService.getProfilePochakPosts(handle: handle, request: request) { data, failed in
            guard let data = data else {
                switch failed {
                case .clientError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "유효하지 않은 멤버의 handle입니다."), animated: true)
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            self.pochakPostData = data.result
        }
    }
}
