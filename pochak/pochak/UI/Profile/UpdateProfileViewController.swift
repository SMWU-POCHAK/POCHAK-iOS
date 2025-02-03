//
//  UpdateProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//

import UIKit
import Kingfisher

final class UpdateProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let textViewPlaceHolder = "소개를 입력해주세요."
    private let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
    private let email = UserDefaultsManager.getData(type: String.self, forKey: .email) ?? "email not found"
    private let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    private let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
    private let message = UserDefaultsManager.getData(type: String.self, forKey: .message) ?? "message not found"
    private let profileImgUrl = UserDefaultsManager.getData(type: String.self, forKey: .profileImgUrl) ?? "profileImgUrl not found"
    private let imagePickerController = UIImagePickerController()
    private var userSelectedPhoto: UIImage?
    
    // MARK: - Views

    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor(named: "gray03"), for: .normal)
        button.isEnabled = false
        button.titleLabel?.font =  UIFont(name: "Pretendard-Bold", size: 16)
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
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
        tf.addTarget(self, action: #selector(nicknameTextFieldDidChange), for: .editingChanged)
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
        tf.isUserInteractionEnabled = false
        tf.textColor = UIColor(named: "gray03")
        tf.font = UIFont(name: "Pretendard-Medium", size: 16)
        return tf
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
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.text = "소개를 입력해주세요."
        view.font = UIFont(name: "Pretendard-Medium", size: 16)
        view.textColor = UIColor(named: "gray03")
        view.isScrollEnabled = false
        view.delegate = self
        return view
    }()
    
    private let borderLine3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "gray01")
        return view
    }()
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigation()
        addViews()
        setupConstraints()
        
        setupUserData()
        
        setupKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    
    @objc private func keyboardWillShow(_ sender: NSNotification) {
        // currentTextField : UIResponder.currentResponder로부터 현재 응답을 받고 있는 UITextField
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let currentTextField = UIResponder.currentResponder as? UITextView else { return }

        let keyboardYTop = keyboardFrame.cgRectValue.origin.y
        
        // convertedTextFieldFrame : 현재 선택한 textField의 frame을 해당 텍스트 필드의 superview에서 view cooridnate system으로 변환
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from : currentTextField.superview)
        
        // textFieldYBottom : 텍스트필드 하단의 y값 = 텍스트필드의 y값(=y축 위치) + 텍스트필드의 높이
        let textFieldYBottom = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        // textField 하단이 키보드 상단보다 높을 때 view의 높이를 조정
        if textFieldYBottom > keyboardYTop {
            let textFieldYTop = convertedTextFieldFrame.origin.y
            let properTextFieldHeight = textFieldYTop - keyboardYTop / 1.3
            view.frame.origin.y = -properTextFieldHeight
        }
    }

    @objc private func keyboardWillHide(_ sender: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func profileImageButtonDidTap(_ sender: Any) {
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func nicknameTextFieldDidChange() {
        configureDoneButton()
    }
    
    @objc private func doneButtonDidTap(_ sender: Any) {
        print("== doneButtonDidTap ==")
        guard let nickname = nicknameTextField.text else { return }
        var selfIntro = selfIntroTextView.text!
        print("selfIntro: \(selfIntro)")
        if selfIntro == textViewPlaceHolder {
            selfIntro = ""
        }
        print("cur selfIntro: \(selfIntro)")
        
        // 프로필 이미지 변경 여부에 따라 데이터 값 가져오기
        var profileImageData: Data?
        if let userSelectedPhoto = userSelectedPhoto {
            profileImageData = userSelectedPhoto.jpegData(compressionQuality: 0.2)
        }
        else {
            profileImageData = profileImageButton.imageView?.image?.jpegData(compressionQuality: 0.2)
        }
        
        let request = ProfileUpdateRequest(name: nickname, message: selfIntro)
        var files: [(Data, String, String)] = []
        if let profileImageFile = profileImageData {
            let fileTuple: (Data, String, String) = (profileImageFile, "profileImage", "image/jpeg")
            files.append(fileTuple)
        }
        
        ProfileService.profileUpdate(handle: handle, files: files, request: request) { [weak self] data, failed in
            guard let data = data else {
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
            
            // UserDefaults 정보 업데이트
            UserDefaultsManager.setData(value: data.result.name, key: .name)
            UserDefaultsManager.setData(value: data.result.handle, key: .handle)
            UserDefaultsManager.setData(value: data.result.message, key: .message)
            UserDefaultsManager.setData(value: data.result.profileImage, key: .profileImgUrl)
            
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Layout
    
    private func addViews() {
        view.addSubview(profileImageButton)
        
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(borderLine1)
        
        view.addSubview(idLabel)
        view.addSubview(idTextField)
        view.addSubview(borderLine2)
        
        view.addSubview(selfIntroLabel)
        view.addSubview(selfIntroTextView)
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
            nicknameLabel.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 40)
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
            idTextField.trailingAnchor.constraint(equalTo: nicknameTextField.trailingAnchor),
            idTextField.leadingAnchor.constraint(equalTo: nicknameTextField.leadingAnchor),
            idTextField.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            borderLine2.heightAnchor.constraint(equalToConstant: 1),
            borderLine2.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            borderLine2.trailingAnchor.constraint(equalTo: borderLine1.trailingAnchor),
            borderLine2.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 14)
        ])
        
        NSLayoutConstraint.activate([
            selfIntroLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            selfIntroLabel.topAnchor.constraint(equalTo: borderLine2.bottomAnchor, constant: 14)
        ])
        NSLayoutConstraint.activate([
            selfIntroTextView.leadingAnchor.constraint(equalTo: nicknameTextField.leadingAnchor),
            selfIntroTextView.trailingAnchor.constraint(equalTo: nicknameTextField.trailingAnchor),
            selfIntroTextView.topAnchor.constraint(equalTo: selfIntroLabel.topAnchor),
        ])
        NSLayoutConstraint.activate([
            borderLine3.heightAnchor.constraint(equalToConstant: 1),
            borderLine3.leadingAnchor.constraint(equalTo: selfIntroLabel.leadingAnchor),
            borderLine3.trailingAnchor.constraint(equalTo: selfIntroTextView.trailingAnchor),
            borderLine3.topAnchor.constraint(equalTo: selfIntroTextView.bottomAnchor, constant: 12)
        ])
    }
    
    // MARK: - Functions
    
    private func setupNavigation() {
        self.navigationItem.title = "프로필 수정"
        
        let barButtonItem = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupUserData() {
        self.nicknameTextField.text = name
        self.idTextField.text = handle
        if message == "" {
            self.selfIntroTextView.text = textViewPlaceHolder
            self.selfIntroTextView.textColor = UIColor(named: "gray03")
        }
        else {
            self.selfIntroTextView.text = message
            self.selfIntroTextView.textColor = .black
        }

        if let url = URL(string: profileImgUrl) {
            // TODO: 뭔가 비효율적인가??
            let imageView = UIImageView()
            imageView.load(with: url)
            self.profileImageButton.setImage(imageView.image, for: .normal)
        }
    }
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 프로필 정보 변경사항이 있을 때만 완료 버튼 활성화
    private func configureDoneButton() {
        print("=== configure done button ===")
        let nickname = nicknameTextField.text
        let intro = selfIntroTextView.text!
        let isValidChangeInNickname = (nickname != name && nickname != "") ? true : false
        print("nickname: \(nickname)")
        print("isValidChangeInNickname: \(isValidChangeInNickname)")
        print("intro: \(intro)")
        
        // 유효한 변경사항 있을 때
        if isValidChangeInNickname || intro != message || userSelectedPhoto != nil {
            print(">> 유효한 변경사항")
            doneButton.setTitleColor(UIColor(named: "yellow00"), for: .normal)
            doneButton.isEnabled = true
        }
        // 없을 때
        else {
            print(">> 유효하지 않은 변경사항")
            doneButton.setTitleColor(UIColor(named: "gray03"), for: .normal)
            doneButton.isEnabled = false
        }
    }
}

// MARK: - Extension: UIImagePickerControllerDelegate

extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 선택한 사진 사용
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageButton.setImage(image, for: .normal)
            userSelectedPhoto = image
            configureDoneButton()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension UpdateProfileViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
            configureDoneButton()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor(named: "gray03")
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
        configureDoneButton()
        
        guard let text = textView.text else { return }
        
        let maxNumberOfLines = 3
        let lineBreakCharacter = "\n"
        let lines = text.components(separatedBy: lineBreakCharacter)
        var consecutiveLineBreakCount = 0 // 연속된 줄 바꿈 횟수
        
        for _ in lines {
            consecutiveLineBreakCount += 1
            if consecutiveLineBreakCount > maxNumberOfLines {
                textView.text = String(text.dropLast()) // 마지막 입력 문자를 제거
                break
            }
        }
    }
}

// MARK: - Extension; CustomAlertDelegate

extension UpdateProfileViewController: CustomAlertDelegate {
    
    func confirmAction() {
        print("confirmed")
    }
    
    func cancel() {
        print("canceled")
    }
}
