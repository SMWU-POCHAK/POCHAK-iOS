//
//  PreviewAlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 6/30/24.
//

import UIKit

final class PreviewAlarmViewController: UIViewController {
    
    // MARK: - Properties
    
    var acceptButtonAction: (() -> Void)?
    var refuseButtonAction: (() -> Void)?
    
    var tagId: Int?
    var alarmId: Int?
        
    @IBAction func acceptBtnTapped(_ sender: Any) {
        acceptButtonAction?()
        guard let tagId = tagId else {
            print("tagId is nil")
            return
        }
        postTagData(tagId: tagId, isAccept: true)
    }
    
    @IBAction func refuseBtnTapped(_ sender: Any) {
        refuseButtonAction?()
        guard let tagId = tagId else {
            print("tagId is nil")
            return
        }
        postTagData(tagId: tagId, isAccept: false)
    }
    
    // MARK: - Views
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var taggedUsers: UILabel!
    @IBOutlet weak var pochakUser: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttribute()
        getTagPreviewData(alarmId: alarmId!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 모달 창의 높이 설정
        preferredContentSize = CGSize(width: view.frame.width, height: postImageView.frame.maxY + 13)
    }
    
    // MARK: - Functions
    
    private func setupAttribute() {
        self.profileImageView?.layer.cornerRadius = 50/2
    }
    
    func postTagData(tagId: Int, isAccept: Bool) {
        showProgressBar()
//        PreviewAlarmDataService.shared.postTagAccept(tagId: tagId, isAccept: isAccept){ [self] response in
//            // 함수 호출 후 프로그래스 바 숨기기
//            defer {
//                hideProgressBar()
//                dismiss(animated: true) {
//                    NotificationCenter.default.post(name: Notification.Name("ModalDismissed"), object: nil)
//                }
//            }
//            switch response {
//            case .success(let data):
//                print(data)
//            case .requestErr(let err):
//                print(err)
//            case .pathErr:
//                print("pathErr")
//            case .serverErr:
//                print("serverErr")
//            case .networkFail:
//                print("networkFail")
//            }
//        }
    }
    
    func getTagPreviewData(alarmId: Int) {
        print("======= \(alarmId)번의 알람 미리보기 합니다 =======")
        AlarmService.getTagPreview(alarmId: alarmId) { [weak self] data, failed in
            guard let data = data else {
                // 에러가 난 경우, alert 창 present
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
            
            guard let self = self else { return }
            
            let previewDataResult = data.result
            
            if let url = URL(string: previewDataResult.ownerProfileImage) {
                profileImageView.load(with: url)
                profileImageView.contentMode = .scaleAspectFill
            }
            
            var taggedUserString = ""
            
            let tagList = previewDataResult.tagList
            for taggedMember in tagList {
                if taggedMember.handle == tagList.last?.handle {
                    taggedUserString += "\(taggedMember.handle) 님"
                }
                else {
                    taggedUserString += "\(taggedMember.handle) 님 • "
                }
            }
            taggedUsers.text = taggedUserString
            
            if let pochakUser = self.pochakUser {
                pochakUser.text = (previewDataResult.ownerHandle ?? "사용자") + "님이 포착"
            } else {
                print("pochakUser is nil")
            }
            
            if let url = URL(string: previewDataResult.postImage) {
                postImageView.load(with: url)
            }
        }
    }
}

