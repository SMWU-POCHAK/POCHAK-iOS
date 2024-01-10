//
//  MakeProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/14.
//

import UIKit

class MakeProfileViewController: UIViewController {
    
    var accessToken: String!
    
    let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "socialType not found"
    let email = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "socialType not found"
    let socialType = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "socialType not found"
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "socialId not found"


    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Add Navigation Item
        // 완료 버튼
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(named: "yellow00"), for: .normal)
        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 18)
        button.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        // Title
        self.navigationItem.title = "프로필 설정"
        
        // Name 항목 채워넣기
        nameTextField.text = name
        
        // Back 버튼
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    
    // MARK: - 프로필 설정 완료 시 changeRootViewController
    @objc private func doneBtnTapped(_ sender: Any) {
        
        // userDefault에 데이터 추가
        guard let handle = handleTextField.text  else {return}
        guard let message = messageTextField.text  else {return}
        guard let profileImage = profileImg.image  else {return}
        
        UserDefaultsManager.setData(value: handle, key: .handle)
        UserDefaultsManager.setData(value: message, key: .message)
        
        // request : POST
        JoinDataManager.shared.joinDataManager(accessToken, 
                                               name,
                                               email,
                                               handle,
                                               message,
                                               socialId,
                                               socialType,
                                               profileImage,
                                               {resultData in
            guard let isNewMember = resultData.isNewMember else { return }
            // 토큰 저장
            TokenUtils().create("url주소", account: "accessToken", value: self.accessToken)
            print(isNewMember)
        })
        
        
        // 화면 전환
        guard let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC") as? TabbarController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabbarVC, animated: false)
    }
    
    // MARK: - 프로필 사진 설정
    /*
    1. 권한 설정 : Info.plist > Photo Library Usage 권한 추가
    2. UIImagePickerController 선언
    3. @IBAction 정의
    4. 프로토콜 채택
     */
    let imagePickerController = UIImagePickerController()
    @IBAction func profileBtnTapped(_ sender: Any) {
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }
   
    
}

// 앨범 사진 선택 프로토콜 채택
extension MakeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 선택한 사진 사용
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImg.image = image
        }
        picker.dismiss(animated: true, completion: nil) // 주의점 : picker 숨기기 위한 dismiss를 직접 해야함
    }
    
    // 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
