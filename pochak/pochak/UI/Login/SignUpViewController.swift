//
//  SignUpViewController.swift
//  pochak
//
//  Created by Seo Cindy on 2023/08/14.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    // MARK: - Properties
        
    private var backBtnPressed: Bool = false
    private var handleDuplicationChecked: Bool = false
    private let textViewPlaceHolder = "소개를 입력해주세요."
    private let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    private let socialType = UserDefaultsManager.getData(type: String.self, forKey: .socialType) ?? "socialType not found"
    private let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    private let socialRefreshToken = UserDefaultsManager.getData(type: String.self, forKey: .socialRefreshToken) ?? "NOTAPPLELOGINUSER"
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - Views
    
//    @IBOutlet weak var profileImg: UIButton!
//    @IBOutlet weak var nameTextField: UITextField!
//    @IBOutlet weak var handleTextField: UITextField!
//    @IBOutlet weak var messageTextView: UITextView!
//    @IBOutlet weak var checkHandleDuplicationBtn: UIButton!
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(named: "yellow00"), for: .normal)
        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 16)
//        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let profileImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "PlusIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(profileImageButtonDidTap), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "gray01")
        button.clipsToBounds = true
        button.layer.cornerRadius = 116 / 2
        return button
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "닉네임"
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "닉네임을 입력해주세요."
        tf.font = UIFont(name: "Pretendard-Medium", size: 16)
        return tf
    }()
    
    private let borderLine1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "gray01")
        return view
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "아이디"
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        return label
    }()
    
    private lazy var idTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "아이디를 입력해주세요."
        tf.font = UIFont(name: "Pretendard-Medium", size: 16)
        tf.addTarget(self, action: #selector(idTextFieldDidChange), for: .editingChanged)
        tf.delegate = self
        return tf
    }()
    
    private let idValidationCheckImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "CheckIcon")
        view.isHidden = true
        return view
    }()
    
    private let idRuleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "영문, 숫자, 밑줄, 마침표의 조합으로 15자 이내"
        label.font = UIFont(name: "Pretendard-Regular", size: 13)
        label.textColor = UIColor(named: "gray03")
        return label
    }()
    
    private let handleDuplicateCheckButton: HandleDuplicateCheckButton = {
        let button = HandleDuplicateCheckButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDuplicateCheckButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let borderLine2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "gray01")
        return view
    }()
    
    private let selfIntroLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "소개"
        label.font = UIFont(name: "Pretendard-Bold", size: 16)
        return label
    }()
    
    private lazy var selfIntroTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textContainer.lineFragmentPadding = 0  // textView 기본 마진 제거
        view.textContainerInset = .zero  // textView 기본 마진 제거
        view.text = "소개를 입력해주세요."  // PlaceHolder 커스텀
        view.font = UIFont(name: "Pretendard-Medium", size: 16)
        view.textColor = UIColor(named: "gray03") // PlaceHolder 커스텀
        view.isScrollEnabled = false
        view.delegate = self
        return view
    }()
    
    private let selfIntroRuleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "최대 50자, 3줄 이내"
        label.font = UIFont(name: "Pretendard-Regular", size: 13)
        label.textColor = UIColor(named: "gray03")
        return label
    }()
    
    private let borderLine3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "gray01")
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigation()
//        setupIntroTextView()
        
        addViews()
        setupConstraints()
        
        selfIntroTextView.text = textViewPlaceHolder
        
        print(selfIntroTextView.text)
        //setUpViewController()
        //setUpNavigationBar()
    }
    
    // MARK: - Actions
    
    @objc private func handleDuplicateCheckButtonDidTap(_ sender: Any) {
        guard let handle = idTextField.text else { return }
        
        // 아이디가 빈 문자열일 때 api 요청 보내지 않기 위해 알람창을 띄움
        if handle == "" {
            self.showAlert(alertType: .confirmOnly,
                           titleText: "아이디를 입력해주세요.",
                           confirmButtonText: "확인")
            return
        }
        
        // 아이디가 규칙을 안 지켰을 때 api 요청 보내지 않기 위해
        if idTextField.text!.checkHandleValidity() == false {
            self.showAlert(alertType: .confirmOnly,
                           titleText: "아이디가 유효하지 않습니다.",
                           messageText: "입력한 아이디를 확인해주세요.",
                           confirmButtonText: "확인")
            return
        }
        
        let request = CheckDuplicateHandleRequest(handle: handle)
        
        AuthenticationService.checkDuplicateHandle(request: request) { [weak self] data, failed in
            guard let data = data else { return }
            
            let code = data.code
            let memberCode = MemberCode(rawValue: code)
            
            switch memberCode {
            case .success:
                self?.handleDuplicateCheckButton.isActive = false
                self?.handleDuplicationChecked = true
            case .duplicationError:
                self?.showAlert(alertType: .confirmOnly,
                                titleText: "중복된 아이디입니다.",
                                messageText: "다른 아이디를 입력해주세요.",
                                cancelButtonText: "",
                                confirmButtonText: "확인")
            case .unknown:
                print("Unknown code: \(code)")
            }
        }
    }
    
    // 프로필 사진 설정
    /*
     1. 권한 설정: Info.plist > Photo Library Usage 권한 추가
     2. UIImagePickerController 선언
     3. @IBAction 정의
     4. 프로토콜 채택
     */
    @objc func profileImageButtonDidTap(_ sender: Any) {
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func backbuttonPressed(_ sender: Any) {
        backBtnPressed = true
        showAlert(alertType: .confirmAndCancel,
                  titleText: "프로필 설정을 취소하고\n페이지를 나갈까요?",
                  messageText: "페이지를 벗어나면 현재 입력된 내용은\n저장되지 않으며, 모두 사라집니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
    }
    
    @objc private func idTextFieldDidChange(_ sender: Any?) {
        handleDuplicationChecked = false
        handleDuplicateCheckButton.isActive = true
        if idTextField.text!.checkHandleValidity() {
            idValidationCheckImageView.isHidden = false
            idRuleLabel.textColor = UIColor(named: "blue")
        }
        else {
            idValidationCheckImageView.isHidden = true
            idRuleLabel.textColor = UIColor(named: "red")
        }
    }
    
//    @objc private func doneButtonDidTap(_ sender: Any) {
//        guard let name = nameTextField.text  else { return }
//        guard let handle = handleTextField.text  else { return }
//        guard let message = messageTextView.text  else { return }
//        guard let profileImage = profileImg.currentImage  else { return }
//        let profileImageData: Data? = profileImg.currentImage?.jpegData(compressionQuality: 0.2)
//        
//        if (name == "" || handle == "" || message == textViewPlaceHolder || message == ""
//            || profileImage == UIImage(named: "chooseProfileIcon")) {
//            showAlert(alertType: .confirmOnly,
//                      titleText: "프로필 정보를 모두 입력해주세요.",
//                      messageText: "",
//                      cancelButtonText: "",
//                      confirmButtonText: "확인")
//            return
//        } else if !handleDuplicationChecked {
//            showAlert(alertType: .confirmOnly,
//                      titleText: "아이디 중복확인을 진행해주세요.",
//                      messageText: "",
//                      cancelButtonText: "",
//                      confirmButtonText: "확인")
//            return
//        } else {
//            let request = SignUpRequest(name: name,
//                                        email: email,
//                                        handle: handle,
//                                        message: message,
//                                        socialId: socialId,
//                                        socialType: socialType)
//            
//            var files: [(Data, String, String)] = []
//            if let profileImage = profileImageData {
//                let fileTuple: (Data, String, String) = (profileImage, "profileImage", "image/jpeg")
//                files.append(fileTuple)
//            }
//            
//            AuthenticationService.signUp(request: request, files: files) { [weak self] data, failed in
//                guard let data = data else { return }
//                
//                // 새로운 유저 정보 UserDefaults에 저장: id, name, handle, message, isNewMember
//                UserDefaultsManager.setData(value: data.result.name, key: .name)
//                UserDefaultsManager.setData(value: data.result.id, key: .memberId)
//                UserDefaultsManager.setData(value: handle, key: .handle)
//                UserDefaultsManager.setData(value: message, key: .message)
//                UserDefaultsManager.setData(value: data.result.isNewMember, key: .isNewMember)
//                
//                // 유저 토큰 정보 KeyChainManager에 저장
//                guard let accountAccessToken = data.result.accessToken else { return }
//                guard let accountRefreshToken = data.result.refreshToken else { return }
//                do {
//                    try KeychainManager.save(account: "accessToken", value: accountAccessToken, isForce: true)
//                    try KeychainManager.save(account: "refreshToken", value: accountRefreshToken, isForce: true)
//                } catch {
//                    print(error)
//                }
//                self?.saveRefreshTokenIssuedAt()
//                self?.toHomeTabPage()
//            }
//        }
//    }
    
    // MARK: - Layout
    
    private func setupNavigation() {
        self.navigationItem.title = "프로필 설정"
        
        let barButtonItem = UIBarButtonItem(customView: doneButton)
        
        // left bar button을 추가하면 기존의 스와이프 pop 기능이 해제되므로 다시 세팅
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func addViews() {
        view.addSubview(profileImageButton)
        
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(borderLine1)
        
        view.addSubview(idLabel)
        view.addSubview(idTextField)
        view.addSubview(handleDuplicateCheckButton)
        view.addSubview(idValidationCheckImageView)
        view.addSubview(idRuleLabel)
        view.addSubview(borderLine2)
        
        view.addSubview(selfIntroLabel)
        view.addSubview(selfIntroTextView)
        view.addSubview(selfIntroRuleLabel)
        view.addSubview(borderLine3)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 116),
            profileImageButton.heightAnchor.constraint(equalTo: profileImageButton.widthAnchor, multiplier: 1),
            profileImageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nicknameLabel.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 41)
        ])
        NSLayoutConstraint.activate([
            nicknameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nicknameTextField.widthAnchor.constraint(equalToConstant: 245),
            nicknameTextField.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            borderLine1.heightAnchor.constraint(equalToConstant: 1),
            borderLine1.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            borderLine1.trailingAnchor.constraint(equalTo: nicknameTextField.trailingAnchor),
            borderLine1.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 14)
        ])
        
        NSLayoutConstraint.activate([
            idLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            idLabel.topAnchor.constraint(equalTo: borderLine1.bottomAnchor, constant: 17)
        ])
        NSLayoutConstraint.activate([
            //idTextField.trailingAnchor.constraint(equalTo: handleDuplicateCheckButton.leadingAnchor, constant: -5),
            idTextField.leadingAnchor.constraint(equalTo: nicknameTextField.leadingAnchor),
            idTextField.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            handleDuplicateCheckButton.leadingAnchor.constraint(greaterThanOrEqualTo: idTextField.trailingAnchor, constant: 5),
            handleDuplicateCheckButton.trailingAnchor.constraint(equalTo: nicknameTextField.trailingAnchor),
            handleDuplicateCheckButton.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            idRuleLabel.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor),
            idRuleLabel.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: 8)
        ])
        NSLayoutConstraint.activate([
            idValidationCheckImageView.trailingAnchor.constraint(equalTo: idRuleLabel.leadingAnchor, constant: -5),
            idValidationCheckImageView.centerYAnchor.constraint(equalTo: idRuleLabel.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            borderLine2.heightAnchor.constraint(equalToConstant: 1),
            borderLine2.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            borderLine2.trailingAnchor.constraint(equalTo: handleDuplicateCheckButton.trailingAnchor),
            borderLine2.topAnchor.constraint(equalTo: idRuleLabel.bottomAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            selfIntroLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            selfIntroLabel.topAnchor.constraint(equalTo: borderLine2.bottomAnchor, constant: 17)
        ])
        NSLayoutConstraint.activate([
            selfIntroTextView.leadingAnchor.constraint(equalTo: nicknameTextField.leadingAnchor),
            selfIntroTextView.trailingAnchor.constraint(equalTo: nicknameTextField.trailingAnchor),
            selfIntroTextView.topAnchor.constraint(equalTo: selfIntroLabel.topAnchor),
            selfIntroTextView.heightAnchor.constraint(equalTo: idTextField.heightAnchor)
        ])
        NSLayoutConstraint.activate([
            selfIntroRuleLabel.leadingAnchor.constraint(equalTo: selfIntroTextView.leadingAnchor),
            selfIntroRuleLabel.topAnchor.constraint(equalTo: selfIntroTextView.bottomAnchor, constant: 8),
        ])
        NSLayoutConstraint.activate([
            borderLine3.heightAnchor.constraint(equalToConstant: 1),
            borderLine3.leadingAnchor.constraint(equalTo: selfIntroLabel.leadingAnchor),
            borderLine3.trailingAnchor.constraint(equalTo: selfIntroTextView.trailingAnchor),
            borderLine3.topAnchor.constraint(equalTo: selfIntroRuleLabel.bottomAnchor, constant: 12)
        ])
    }
    
    // MARK: - Functions
    
    private func setupIntroTextView() {
        selfIntroTextView.delegate = self
        selfIntroTextView.textContainer.lineFragmentPadding = 0  // textView 기본 마진 제거
        selfIntroTextView.textContainerInset = .zero  // textView 기본 마진 제거
        selfIntroTextView.text = "소개를 입력해주세요."  // PlaceHolder 커스텀
        selfIntroTextView.textColor = UIColor(named: "gray03") // PlaceHolder 커스텀
    }
    
//    private func setUpViewController() {
//        // 프로필 image 레이아웃
//        profileImg.setImage(UIImage(named: "chooseProfileIcon"), for: .normal)
//        profileImg.imageView?.contentMode = .scaleAspectFill
//        profileImg.layer.masksToBounds = true
//        profileImg.layer.cornerRadius = 58
//        
//        // textView 레이아웃 설정
//        messageTextView.delegate = self
//        messageTextView.textContainer.lineFragmentPadding = 0 // textView 기본 마진 제거
//        messageTextView.textContainerInset = .zero // textView 기본 마진 제거
//        messageTextView.text = textViewPlaceHolder // PlaceHolder 커스텀
//        messageTextView.textColor = UIColor(named: "gray03") // PlaceHolder 커스텀
//        
//        // 중복확인 버튼 기본 이미지 세팅
//        checkHandleDuplicationBtn.setImage(UIImage(named: "checkHandle"), for: .normal)
//        
//        // 핸들 입력 중이면 중복확인 버튼 및 텍스트필드 글자 색 세팅 원래대로 변경
//        handleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//        handleTextField.delegate = self
//    }
    
//    private func setUpNavigationBar() {
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        
//        // 네비게이션바 완료 버튼 커스텀
//        let button = UIButton()
//        button.setTitle("완료", for: .normal)
//        button.setTitleColor(UIColor(named: "yellow00"), for: .normal)
//        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 16)
//        button.addTarget(self, action: #selector(doneBtnTapped), for: .touchUpInside)
//        let barButton = UIBarButtonItem(customView: button)
//        self.navigationItem.rightBarButtonItem = barButton
//        
//        // 네비게이션바 title 커스텀
//        self.navigationController?.navigationBar.tintColor = .black
//        self.navigationItem.title = "프로필 설정"
//        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)]
//        
//        // 네비게이션바 Back 버튼 커스텀
//        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "ChevronLeft")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backbuttonPressed))
//        backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
//        self.navigationItem.leftBarButtonItem = backBarButtonItem
//    }
    
    private func toHomeTabPage() {
        let tabBarController = CustomTabBarController()
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        guard let delegate = sceneDelegate else { return }
        delegate.window?.rootViewController = tabBarController
    }
    
    private func saveRefreshTokenIssuedAt() {
        let issuedAt = Date() // 현재 시간 저장
        UserDefaultsManager.setData(value: issuedAt, key: .refreshTokenIssuedAt)
    }
}

// MARK: - Extension: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 선택한 사진 사용
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageButton.setImage(image, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil) // 주의점: picker 숨기기 위한 dismiss를 직접 해야함
    }
    
    // 사진 선택 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension: UITextViewDelegate

extension SignUpViewController: UITextViewDelegate {
    
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
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= 50
    }
    
    // 최대 줄 수 3줄 제한
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
                
        textView.constraints.forEach { (constraint) in
            // 25 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height <= 25 {
                    
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        
        guard let text = textView.text else { return }
        
        // 줄바꿈(들여쓰기) 제한
        let maxNumberOfLines = 3
        let lineBreakCharacter = "\n"
        let lines = text.components(separatedBy: lineBreakCharacter)
        var consecutiveLineBreakCount = 0 // 연속된 줄 바꿈 횟수
        
        print("lines == \(lines)")
        for _ in lines {
            consecutiveLineBreakCount += 1
            if consecutiveLineBreakCount > maxNumberOfLines {
                textView.text = String(text.dropLast()) // 마지막 입력 문자를 제거
                break
            }
        }
    }
}

// MARK: - Extension: UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 백스페이스 처리 (백스페이스도 text로 처리되기 때문) + 글자 수 제한
        let utf8Char = string.cString(using: .utf8)
        let isBackSpace = strcmp(utf8Char, "\\b")
        if isBackSpace == -92 || textField.text!.count < 15 { return true }
        return false
    }
}

// MARK: - Extension: CustomAlertDelegate

extension SignUpViewController: CustomAlertDelegate {
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

// MARK: - Extension: UIGestureRecognizerDelegate

extension SignUpViewController: UIGestureRecognizerDelegate { }
