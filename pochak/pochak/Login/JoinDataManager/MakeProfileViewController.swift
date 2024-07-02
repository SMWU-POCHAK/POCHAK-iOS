//
//  MakeProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/14.
//

import UIKit

class MakeProfileViewController: UIViewController {
        
    // MARK: - Data
    let textViewPlaceHolder = "소개를 입력해주세요.(최대 50자, 3줄)"
    let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
    let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    let socialType = UserDefaultsManager.getData(type: String.self, forKey: .socialType) ?? "socialType not found"
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    let socialRefreshToken = UserDefaultsManager.getData(type: String.self, forKey: .socialRefreshToken) ?? "NOTAPPLELOGINUSER"

    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바 완료 버튼 커스텀
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(named: "yellow00"), for: .normal)
        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 16)
        button.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        // 네비게이션바 title 커스텀
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "프로필 설정"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        // 네비게이션바 Back 버튼 커스텀
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        // Name 항목 채워넣기
        nameTextField.text = name
        
        // 프로필 image 레이아웃
        profileImg.imageView?.contentMode = .scaleAspectFill
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = 58
        
        // textView 레이아웃 설정
        messageTextView.delegate = self
        messageTextView.textContainer.lineFragmentPadding = 0 // textView 기본 마진 제거
        messageTextView.textContainerInset = .zero // textView 기본 마진 제거
        messageTextView.text = textViewPlaceHolder // PlaceHolder 커스텀
        messageTextView.textColor = UIColor(named: "gray03") // PlaceHolder 커스텀
    }

    // MARK: - Function
    
    @objc private func doneBtnTapped(_ sender: Any) {
        
        // 새로운 유저 정보 UserDefaults에 저장 : name / handle / message
        guard let name = nameTextField.text  else {return}
        guard let handle = handleTextField.text  else {return}
        guard let message = messageTextView.text  else {return}
        guard let profileImage = profileImg.currentImage  else {return}
        print("----------- message : \(name) --------------")
        print("----------- message : \(handle) --------------")
        print("----------- message : \(message) --------------")
        print("----------- message : \(profileImage) --------------")
        print("----------- message : \(email) --------------")
        print("----------- message : \(socialId) --------------")
        print("----------- message : \(socialType) --------------")
        print("----------- message : \(socialRefreshToken) --------------")
        
        // API request : POST
        JoinDataManager.shared.joinDataManager(name,
                                               email,
                                               handle,
                                               message,
                                               socialId,
                                               socialType,
                                               socialRefreshToken,
                                               profileImage,
                                               {resultData in
            
            print("JoinDataManager resultData : \(resultData)")
            
            
            // 새로운 유저 정보 UserDefaults에 저장 : id / name / handle / message / IsNewMember
            UserDefaultsManager.setData(value: resultData.name, key: .name)
            UserDefaultsManager.setData(value: resultData.id, key: .memberId)
            UserDefaultsManager.setData(value: handle, key: .handle)
            UserDefaultsManager.setData(value: message, key: .message)
            UserDefaultsManager.setData(value: resultData.isNewMember, key: .isNewMember)

            
            
            // 유저 토큰 정보 저장 @KeyChainManager
            guard let accountAccessToken = resultData.accessToken else { return }
            guard let accountRefreshToken = resultData.refreshToken else { return }
            print("JoinDataManager accountAccessToken = \(accountAccessToken)")
            print("JoinDataManager accountRefreshToken = \(accountRefreshToken)")
            
            do {
                try KeychainManager.save(account: "accessToken", value: accountAccessToken, isForce: true)
                try KeychainManager.save(account: "refreshToken", value: accountRefreshToken, isForce: true)
            } catch {
                print(error)
            }
            
            // 회원가입 성공 시 홈 화면으로  전환
            self.toHomeTabPage()
        })
        
    }
    
    // 프로필 사진 설정
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
    
    private func toHomeTabPage(){
        
        let tabBarController = CustomTabBarController()
        
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        guard let delegate = sceneDelegate else {
            return
        }
        delegate.window?.rootViewController = tabBarController
    }
}

// MARK: - Extension

// 앨범 사진 선택 프로토콜 채택
extension MakeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 선택한 사진 사용
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImg.setImage(image, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil) // 주의점 : picker 숨기기 위한 dismiss를 직접 해야함
    }
    
    // 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// TextView 기본 속성 설정
extension MakeProfileViewController: UITextViewDelegate {
    
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
