//
//  CustomAlertViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 6/24/24.
//

import UIKit

/// Custom Alert의 버튼의 액션을 처리하는 Delegate
protocol CustomAlertDelegate {
    func confirmAction()   // confirm button event
    func cancel()     // cancel button event
}

class CustomAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    private let alertViewWidth: CGFloat = 270
    private let buttonWidth: CGFloat = 134.5
    
    var alertType: AlertType = .confirmAndCancel
    var titleText = ""
    var messageText = ""
    var cancelButtonText = ""
    var confirmButtonText = ""
    
    var delegate: CustomAlertDelegate?
    
    // MARK: - Views
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buttonBorderLineView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonWidthAnchor: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCustomAlertView()
        
        switch alertType {
        // 확인버튼만 있을 때 -> 스택뷰에 확인버튼만!
        case .confirmOnly:
            cancelButton.isHidden = true
            buttonBorderLineView.isHidden = true
            
            confirmButton.isHidden = false
            confirmButton.setTitle(confirmButtonText, for: .normal)
            confirmButtonWidthAnchor.constant = alertViewWidth
        
        // 확인, 취소 버튼 둘 다 있을 때 -> 버튼 두개와 중간에 뷰 하나!
        case .confirmAndCancel:
            cancelButton.isHidden = false
            cancelButton.setTitle(cancelButtonText, for: .normal)
            
            buttonBorderLineView.isHidden = false
            
            confirmButton.isHidden = false
            confirmButton.setTitle(confirmButtonText, for: .normal)
            confirmButtonWidthAnchor.constant = buttonWidth
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.cancel()
        }
    }
    
    @IBAction func confirmButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.confirmAction()
        }
    }
    
    // MARK: - Functions
    
    private func setCustomAlertView() {
        /// customAlertView 둥글기 적용
        //alertView.layer.cornerRadius = 10
        
        // alert 내용 폰트 설정
        titleLabel.text = titleText
        messageLabel.text = messageText
        
        titleLabel.setLineHeightByPx(value: 3)
        messageLabel.setLineHeightByPx(value: 3)
    }
}

// MARK: - Extension

extension CustomAlertDelegate where Self: UIViewController {
    func showAlert(
        alertType: AlertType,
        titleText: String,
        messageText: String? = "",
        cancelButtonText: String? = "",
        confirmButtonText: String
    ) {
        
        let customAlertStoryboard = UIStoryboard(name: "CustomAlertViewController", bundle: nil)
        let customAlertViewController = customAlertStoryboard.instantiateViewController(withIdentifier: "CustomAlertViewController") as! CustomAlertViewController
        
        customAlertViewController.delegate = self
        
        customAlertViewController.modalPresentationStyle = .overFullScreen
        customAlertViewController.modalTransitionStyle = .crossDissolve
        customAlertViewController.titleText = titleText
        customAlertViewController.messageText = messageText ?? ""
        customAlertViewController.alertType = alertType
        customAlertViewController.cancelButtonText = cancelButtonText ?? ""
        customAlertViewController.confirmButtonText = confirmButtonText
        
        self.present(customAlertViewController, animated: true, completion: nil)
    }
}
