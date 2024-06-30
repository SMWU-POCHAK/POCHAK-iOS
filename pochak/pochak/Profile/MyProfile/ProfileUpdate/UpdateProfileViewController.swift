//
//  UpdateProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//

// 추가로 구현 할 것!!!
// 1. handle 바꾸려고 하면 알림창 뜨게하기

import UIKit

class UpdateProfileViewController: UIViewController {
    
    // MARK: - Data
    
    let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
    let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
    let message = UserDefaultsManager.getData(type: String.self, forKey: .message) ?? "message not found"
    let profileImgUrl = UserDefaultsManager.getData(type: String.self, forKey: .profileImgUrl) ?? "profileImgUrl not found"

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    let imagePickerController = UIImagePickerController()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 네비게이션바 오른쪽 완료 버튼
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(named: "yellow00"), for: .normal)
        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 16)
        button.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        // 네비게이션바 title 커스텀
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "프로필 수정"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        // textfied 데이터 채우기
        nameTextField.text = name
        handleTextField.text = handle
        messageTextField.text = message
        
        // handle 수정 불가하도록 막아두기
//        handleTextField.isUserInteractionEnabled = false
//        handleTextField.textColor = UIColor(named: "gray03")
        
        // 프로필 image 데이터 채우기
        if let url = URL(string: profileImgUrl) {
            self.profileImg.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
        
        // 프로필 image 레이아웃
        self.profileImg.contentMode = .scaleAspectFill
        self.profileImg.layer.cornerRadius = 58

//        // Back 버튼
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Method
    
    @objc private func doneBtnTapped(_ sender: Any) {
        // UserDefaults에 데이터 추가
        guard let name = nameTextField.text  else {return}
        guard let message = messageTextField.text  else {return}
        guard let profileImage = profileImg.image  else {return}

        UserDefaultsManager.setData(value: name, key: .name)
        UserDefaultsManager.setData(value: message, key: .message)
        
        // API request : PATCH
        MyProfileUpdateDataManager.shared.updateDataManager(name,
                                                            handle,
                                                            message,
                                                            profileImage,
                                               {resultData in
            guard let name = resultData.name else { return }
            print(name)
        })
        
        // 프로필 화면으로 전환
        navigationController?.popViewController(animated: true)
    }
    
    /* < 앨범 사진 선택 >
    1. 권한 설정 : Info.plist > Photo Library Usage 권한 추가
    2. UIImagePickerController 선언
    3. @IBAction 정의
    4. 프로토콜 채택
     */
    @IBAction func profileBtnTapped(_ sender: Any) {
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }
}

// MARK: - Extension

// 앨범 사진 선택 프로토콜 채택
extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
