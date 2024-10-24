//
//  MakeProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/14.
//

import UIKit

class MakeProfileViewController: UIViewController {
    
    // MARK: - Data
    let textViewPlaceHolder = "소개를 입력해주세요.\n(최대 50자, 3줄)"
    let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    let socialType = UserDefaultsManager.getData(type: String.self, forKey: .socialType) ?? "socialType not found"
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    let socialRefreshToken = UserDefaultsManager.getData(type: String.self, forKey: .socialRefreshToken) ?? "NOTAPPLELOGINUSER"
    var backBtnPressed : Bool = false
    var handleDuplicationChecked : Bool = false
    
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var checkHandleDuplicationBtn: UIButton!
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationController 스와이프해서 뒤로가기 막기
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
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
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)]
        
        // 네비게이션바 Back 버튼 커스텀
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "ChevronLeft")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backbuttonPressed))
        backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        // self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        
        // 프로필 image 레이아웃
        profileImg.setImage(UIImage(named: "chooseProfileIcon"), for: .normal)
        profileImg.imageView?.contentMode = .scaleAspectFill
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = 58
        
        // textView 레이아웃 설정
        messageTextView.delegate = self
        messageTextView.textContainer.lineFragmentPadding = 0 // textView 기본 마진 제거
        messageTextView.textContainerInset = .zero // textView 기본 마진 제거
        messageTextView.text = textViewPlaceHolder // PlaceHolder 커스텀
        messageTextView.textColor = UIColor(named: "gray03") // PlaceHolder 커스텀
        
        // 중복확인 버튼 기본 이미지 세팅
        checkHandleDuplicationBtn.setImage(UIImage(named: "checkHandle"), for: .normal)
        
        // 핸들 입력 중이면 중복확인 버튼 및 텍스트필드 글자 색 세팅 원래대로 변경
//        handleTextField.placeholder = "아이디를 입력해주세요.\n (대문자, 소문자"
        handleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        handleTextField.delegate = self
    }
    
    // MARK: - Function
    
    @objc private func backbuttonPressed(_ sender: Any) {// 뒤로가기 버튼 클릭시 어디로 이동할지
        backBtnPressed = true
        showAlert(alertType: .confirmAndCancel,
                  titleText: "프로필 설정을 취소하고\n페이지를 나갈까요?",
                  messageText: "페이지를 벗어나면 현재 입력된 내용은\n저장되지 않으며, 모두 사라집니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        handleDuplicationChecked = false
        checkHandleDuplicationBtn.isEnabled = true
        handleTextField.textColor = .black
        checkHandleDuplicationBtn.setImage(UIImage(named: "checkHandle"), for: .normal)
    }
    
    
    @IBAction func checkHandleDuplication(_ sender: Any) {
        guard let handle = handleTextField.text  else {return}
        print(">>>>> checkHandleDuplication handle : \(handle)")
        
        // API request : Get
        CheckHandleDuplicationDataManager.shared.checkHandleDuplicationDataManager(handle) { resultData in
            if resultData.code == "MEMBER2001" {
                // 버튼 변경
                self.checkHandleDuplicationBtn.setImage(UIImage(named: "checkedHandle"), for: .normal)
                self.handleTextField.textColor = UIColor(named: "yellow00")
                // 버튼 disable 시키기
                self.checkHandleDuplicationBtn.isEnabled = false
                self.handleDuplicationChecked = true
            } else if resultData.code == "MEMBER4002" {
                // Alert 창
                self.showAlert(alertType: .confirmOnly,
                               titleText: "중복된 아이디입니다",
                               messageText: "다른 아이디를 입력해주세요.",
                               cancelButtonText: "",
                               confirmButtonText: "확인"
                )
            }
        }
    }
    
    @objc private func doneBtnTapped(_ sender: Any) {
        
        // 새로운 유저 정보 UserDefaults에 저장 : name / handle / message
        guard let name = nameTextField.text  else {return}
        guard let handle = handleTextField.text  else {return}
        guard let message = messageTextView.text  else {return}
        guard let profileImage = profileImg.currentImage  else {return}
        
        if (name == "" || handle == "" || message == textViewPlaceHolder || message == "" || profileImage == UIImage(named: "chooseProfileIcon")){
            print("true!")
            // Alert창
            showAlert(alertType: .confirmOnly,
                      titleText: "프로필 정보를 모두 입력해주세요.",
                      messageText: "",
                      cancelButtonText: "",
                      confirmButtonText: "확인")
            return
        } else if !handleDuplicationChecked {
            showAlert(alertType: .confirmOnly,
                      titleText: "아이디 중복확인을 진행해주세요.",
                      messageText: "",
                      cancelButtonText: "",
                      confirmButtonText: "확인")
            return
        } else {
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

extension MakeProfileViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let utf8Char = string.cString(using: .utf8)
        let isBackSpace = strcmp(utf8Char, "\\b")
        if string.hasCharacters() || isBackSpace == -92{
            return true
        }
        return false
    }
}

// Alert 창
extension MakeProfileViewController : CustomAlertDelegate {
    func cancel() {
        if backBtnPressed {
            self.navigationController?.popViewController(animated: true)
        } else {
            print("cancel button pressed")
        }
    }
    
    
    func confirmAction() {
        print("confirmed")
    }
}

// 아이디 허용 가능한 문자 : 대문자, 소문자, 숫자, _(언더바), .(마침표)
extension String {
    func hasCharacters() -> Bool{
        do{
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z_.]$", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)){
                return true
            }
        }catch{
            print(error.localizedDescription)
            return false
        }
        return false
    }
}
