//
//  ProfileMenuViewController.swift
//  pochak
//
//  Created by Seo Cindy on 6/29/24.
//

import UIKit

class ProfileMenuViewController: UIViewController {

    @IBOutlet weak var userBlockBtn: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var receivedHandle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func userBlockBtnClicked(_ sender: Any) {
        showAlert(alertType: .confirmAndCancel,
                  titleText: "팔로워를 차단하시겠습니까?",
                  messageText: "팔로워를 차단하면, 팔로워와 관련된 \n사진 및 소식을 접할 수 없습니다.",
                  cancelButtonText: "취소",
                  confirmButtonText: "차단하기"
        )
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileMenuViewController: CustomAlertDelegate {
    
    func confirmAction() {
//        BlockDataManager.shared.blockDataManager(receivedHandle ?? "", { resultData in
//            print(resultData.message)
//        })
        print("계정 차단함")
    }
    
    func cancel() {
        print("취소하기 선택됨")
    }
}
