//
//  ProfileMenuViewController.swift
//  pochak
//
//  Created by Seo Cindy on 6/29/24.
//

import UIKit

class ProfileMenuViewController: UIViewController {
    
    // MARK: - Properties
    
    let userHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
    var receivedHandle: String?
    weak var delegate: SecondViewControllerDelegate?
    
    // MARK: - Views
    
    @IBOutlet weak var userBlockBtn: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func userBlockBtnClicked(_ sender: Any) {
        showAlert(alertType: .confirmAndCancel,
                  titleText: "유저를 차단하시겠습니까?",
                  messageText: "유저를 차단하면, 팔로워와 관련된 \n사진 및 소식을 접할 수 없습니다.",
                  cancelButtonText: "취소",
                  confirmButtonText: "차단하기"
        )
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension : CustomAlertDelegate

extension ProfileMenuViewController: CustomAlertDelegate {
    
    func confirmAction() {
        UserService.blockUser(handle: receivedHandle ?? "") { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            print(data.message)
            self?.userBlockBtn.setTitle("차단취소", for: .normal)
            self?.delegate?.dismissSecondViewController()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func cancel() {
        print("취소하기 선택됨")
    }
}
