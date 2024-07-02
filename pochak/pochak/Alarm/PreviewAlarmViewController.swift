//
//  PreviewAlarmViewController.swift
//  pochak
//
//  Created by 장나리 on 6/30/24.
//

import UIKit

class PreviewAlarmViewController : UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var taggedUsers: UILabel!
    @IBOutlet weak var pochakUser: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    
    var acceptButtonAction: (() -> Void)?
    var refuseButtonAction: (() -> Void)?
    
    var taggedUserHandle : [String] = []
    var pochakUserHandle : String?
    var profileImgUrl : String?
    var postImgUrl : String?
    var tagId : Int?
    
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
        getTagPreviewData(tagId: tagId)
    }
    
    @IBAction func refuseBtnTapped(_ sender: Any) {
        refuseButtonAction?()
        guard let tagId = tagId else {
            print("tagId is nil")
            return
        }

        postTagData(tagId: tagId, isAccept: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttribute()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            // 모달 창의 높이 설정
            preferredContentSize = CGSize(width: view.frame.width, height: postImageView.frame.maxY + 13)
        }
    
    private func setupAttribute(){
        self.profileImageView?.layer.cornerRadius = 50/2
    }
    
    private func setupUI(){
        if let profileImageView = self.profileImageView {
            configure(imageview: profileImageView, with: profileImgUrl ?? "")
        } else {
            print("profileImageView is nil")
            // Handle the case where postImageView is nil
        }
        
        //        for handle in taggedUserHandle {
        //            if(handle == taggedUserHandle.last){
        //                self.taggedUsers.text! != handle + " 님"
        //            }
        //            else{
        //                self.taggedUsers.text! != handle + " 님 • "
        //            }
        //        }
        
        if let pochakUser = self.pochakUser {
            pochakUser.text = (self.pochakUserHandle ?? "사용자") + "님이 포착"
        } else {
            print("pochakUser is nil")
            // Handle the case where postImageView is nil
        }
        
        if let postImageView = self.postImageView {
            configure(imageview: postImageView, with: postImgUrl ?? "")
        } else {
            print("postImageView is nil")
            // Handle the case where postImageView is nil
        }
    }
    
    func configure(imageview : UIImageView,with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageview.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                    imageview.contentMode = .scaleAspectFill
                    
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func postTagData(tagId: Int, isAccept: Bool){
        showProgressBar()
        PreviewAlarmDataService.shared.postTagAccept(tagId: tagId, isAccept: isAccept){ [self]
            response in
            
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
    
    func getTagPreviewData(tagId: Int){
        PreviewAlarmDataService.shared.getTagPreview(tagId: tagId){ [self]
            response in
            
            switch response {
            case .success(let data):
                print(data)
                self.previewDataResponse = data as? PreviewAlarmResponse
                self.previewDataResult = self.previewDataResponse.result
                self.tagList = self.previewDataResult.tagList
                
                
                
                if let profileImageView = self.profileImageView {
                    configure(imageview: profileImageView, with: self.previewDataResult.ownerProfileImage ?? "")
                } else {
                    print("profileImageView is nil")
                    // Handle the case where postImageView is nil
                }
                
                if let taggedUsers = self.taggedUsers{
                    for tagList in self.tagList {
                        for handle in tagList.handle{
                            if(handle == tagList.handle.last){
                                self.taggedUsers.text = String(handle) + " 님"
                            }
                            else{
                                self.taggedUsers.text = String(handle) + " 님 • "
                            }
                        }
                    }
                }
                
                if let pochakUser = self.pochakUser {
                    pochakUser.text = (self.previewDataResult.ownerHandle ?? "사용자") + "님이 포착"
                } else {
                    print("pochakUser is nil")
                    // Handle the case where postImageView is nil
                }
                
                if let postImageView = self.postImageView {
                    configure(imageview: postImageView, with: self.previewDataResult.postImage ?? "")
                } else {
                    print("postImageView is nil")
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
    
