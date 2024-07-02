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
    let textViewPlaceHolder = "소개를 입력해주세요.(최대 50자, 3줄)"

    let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
    let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
    let message = UserDefaultsManager.getData(type: String.self, forKey: .message) ?? "message not found"
    let profileImgUrl = UserDefaultsManager.getData(type: String.self, forKey: .profileImgUrl) ?? "profileImgUrl not found"
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleTextField: UITextField!
    
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
        messageTextView.text = message
        
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
        
        // textView 레이아웃 설정
        messageTextView.delegate = self
        messageTextView.textContainer.lineFragmentPadding = 0 // textView 기본 마진 제거
        messageTextView.textContainerInset = .zero // textView 기본 마진 제거
//        messageTextView.text = textViewPlaceHolder // PlaceHolder 커스텀
//        messageTextView.textColor = UIColor(named: "gray03") // PlaceHolder 커스텀

//        // Back 버튼
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Method
    
    @objc private func doneBtnTapped(_ sender: Any) {
        // UserDefaults에 데이터 추가
        guard let name = nameTextField.text  else {return}
        guard let message = messageTextView.text  else {return}
        guard let profileImage = profileImg.image  else {return}
        
        // API request : PATCH
        MyProfileUpdateDataManager.shared.updateDataManager(name,
                                                            handle,
                                                            message,
                                                            profileImage,
                                               {resultData in
            guard let name = resultData.name else { return }
            UserDefaultsManager.setData(value: resultData.name, key: .name)
            UserDefaultsManager.setData(value: resultData.message, key: .message)
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

// TextView 기본 속성 설정
extension UpdateProfileViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor =  UIColor(named: "gray03")
        }
    }
    
    // 최대 글자 수 50자 제한
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {return false}
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= 50
    }
    
    // 최대 줄 수 3줄 제한
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
//        // 글자수 제한
//        let maxLength = 50
//        if text.count > maxLength {
////            textView.text = String(text.prefix(maxLength))
//            textView.text.removeLast()
//        }
//
        // 줄바꿈(들여쓰기) 제한
        let maxNumberOfLines = 3
        let lineBreakCharacter = "\n"
        let lines = text.components(separatedBy: lineBreakCharacter)
        var consecutiveLineBreakCount = 0 // 연속된 줄 바꿈 횟수

        print("lines == \(lines)")
        for line in lines {
//            if line.isEmpty { // 빈 줄이면 연속된 줄 바꿈으로 간주
                consecutiveLineBreakCount += 1
//            }
//            } else {
//                consecutiveLineBreakCount = 0
//            }
            

            if consecutiveLineBreakCount > maxNumberOfLines {
                textView.text = String(text.dropLast()) // 마지막 입력 문자를 제거
                
//                textView.text.removeLast()
                break
            }
        }
    }
}

