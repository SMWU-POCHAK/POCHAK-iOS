//
//  PreviewAlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 6/30/24.
//

import UIKit

class PreviewAlarmViewController: UIViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var taggedUsers: UILabel!
    @IBOutlet weak var pochakUser: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    
    // MARK: - Properties
    
    var acceptButtonAction: (() -> Void)?
    var refuseButtonAction: (() -> Void)?
    
    var taggedUserHandle: [String] = []
    var pochakUserHandle: String?
    var profileImgUrl: String?
    var postImgUrl: String?
    var tagId: Int?
    var alarmId: Int?
    
    private var previewDataResponse: PreviewAlarmResponse!
    private var previewDataResult: PreviewAlarmResult!
    private var tagList: [PreviewTagList]! = []
    
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
        PreviewAlarmDataService.shared.postTagAccept(tagId: tagId, isAccept: isAccept){ [self] response in
            // 함수 호출 후 프로그래스 바 숨기기
            defer {
                hideProgressBar()
                dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name("ModalDismissed"), object: nil)
                }
            }
            switch response {
            case .success(let data):
                print(data)
            case .requestErr(let err):
                print(err)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    func getTagPreviewData(alarmId: Int) {
        print("======= \(alarmId)번의 알람 미리보기 합니다 =======")
        PreviewAlarmDataService.shared.getTagPreview(tagId: alarmId) { [self] response in
            switch response {
            case .success(let data):
                print(data)
                self.previewDataResponse = data as? PreviewAlarmResponse
                self.previewDataResult = self.previewDataResponse.result
                self.tagList = self.previewDataResult.tagList
                
                
                if let profileImageView = self.profileImageView {
                    if let url = URL(string: self.previewDataResult.ownerProfileImage) {
                        profileImageView.load(with: url)
                        profileImageView.contentMode = .scaleAspectFill
                    }
                }
                
                var taggedUserString = ""
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
                    pochakUser.text = (self.previewDataResult.ownerHandle ?? "사용자") + "님이 포착"
                } else {
                    print("pochakUser is nil")
                }
                
                if let postImageView = self.postImageView {
                    if let url = URL(string: self.previewDataResult.postImage) {
                        postImageView.load(with: url)
                    }
                }
                
            case .requestErr(let err):
                print(err)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
}

