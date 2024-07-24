//
//  TermsOfAgreeViewController.swift
//  pochak
//
//  Created by Seo Cindy on 7/7/24.
//

import UIKit
import SafariServices

class TermsOfAgreeViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var pochakLabel: UILabel!
    @IBOutlet weak var pochakCorpLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var agreeForPrivacyPolicy: UIButton!
    @IBOutlet weak var agreeForTermsOfUSe: UIButton!
    @IBOutlet weak var seePrivacyPolicy: UIButton!
    @IBOutlet weak var seeTermsOfUse: UIButton!
    @IBOutlet weak var agreeAndContinueButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    
    var didAgreeForPrivacyPolicy : Bool = false
    var didAgreeForTermsOfUse : Bool = false
    var delegate : SendDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 8
        appIcon.layer.cornerRadius = 5
        agreeAndContinueButton.layer.cornerRadius = 5
        seePrivacyPolicy.setUnderline()
        seeTermsOfUse.setUnderline()
        
        pochakLabel.text = "Pochak"
        pochakLabel.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        pochakLabel.textColor = .black
        
        pochakCorpLabel.text = "Pochak Corp."
        pochakCorpLabel.font = UIFont(name: "Pretendard-Light", size: 16)
        pochakCorpLabel.textColor = UIColor(named: "gray04")
        
        titleLabel.text = "개인정보 및 이용약관 동의 항목"
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        titleLabel.textColor = .black
        
        
        agreeForPrivacyPolicy.setTitle(" [필수] 개인정보 제3자 제공 동의", for: .normal)
        agreeForPrivacyPolicy.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        agreeForPrivacyPolicy.titleLabel?.font =  UIFont(name: "Pretendard-Medium", size: 15)
        agreeForPrivacyPolicy.setTitleColor(UIColor(named: "gray04"), for: .normal)
        agreeForPrivacyPolicy.tintColor = UIColor(named: "gray04")

        
        agreeForTermsOfUSe.setTitle(" [필수] 이용약관 항목", for: .normal)
        agreeForTermsOfUSe.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        agreeForTermsOfUSe.titleLabel?.font =  UIFont(name: "Pretendard-Medium", size: 15)
        agreeForTermsOfUSe.setTitleColor(UIColor(named: "gray04"), for: .normal)
        agreeForTermsOfUSe.tintColor = UIColor(named: "gray04")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressAgreeForPrivacyPolicy(_ sender: Any) {
        if !didAgreeForPrivacyPolicy {
            didAgreeForPrivacyPolicy = true
            agreeForPrivacyPolicy.setTitleColor(UIColor.black, for: .normal)
            agreeForPrivacyPolicy.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            agreeForPrivacyPolicy.tintColor = UIColor.black
        } else if didAgreeForPrivacyPolicy {
            didAgreeForPrivacyPolicy = false
            agreeForPrivacyPolicy.setTitleColor(UIColor(named: "gray04"), for: .normal)
            agreeForPrivacyPolicy.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            agreeForPrivacyPolicy.tintColor = UIColor(named: "gray04")
        }
        
    }
    
    @IBAction func pressAgreeForTermsOfUSe(_ sender: Any) {
        if !didAgreeForTermsOfUse {
            didAgreeForTermsOfUse = true
            agreeForTermsOfUSe.setTitleColor(UIColor.black, for: .normal)
            agreeForTermsOfUSe.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            agreeForTermsOfUSe.tintColor = UIColor.black
        } else if didAgreeForTermsOfUse {
            didAgreeForTermsOfUse = false
            agreeForTermsOfUSe.setTitleColor(UIColor(named: "gray04"), for: .normal)
            agreeForTermsOfUSe.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            agreeForTermsOfUSe.tintColor = UIColor(named: "gray04")
        }
    }
    
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        guard let url = URL(string: "https://pochak.notion.site/e365e34f018949b88543adbe6b0b3746") else { return }
        let safariVC = SFSafariViewController(url: url)
        // delegate 지정 및 presentation style 설정.
        safariVC.transitioningDelegate = self
        safariVC.modalPresentationStyle = .pageSheet

        present(safariVC, animated: true, completion: nil)
    }
    
    
    @IBAction func openTermsOfUSe(_ sender: Any) {
        guard let url = URL(string: "https://pochak.notion.site/6520996186464c36a8b3a04bc17fa000?pvs=74") else { return }
        let safariVC = SFSafariViewController(url: url)
        // delegate 지정 및 presentation style 설정.
        safariVC.transitioningDelegate = self
        safariVC.modalPresentationStyle = .pageSheet

        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func agreeAndContinue(_ sender: Any) {
        if didAgreeForPrivacyPolicy && didAgreeForTermsOfUse {
            self.dismiss(animated: true)
            delegate?.sendAgreed(agree: true)
        } else {
            print("not agreed yet")
        }
    }

}

extension UIButton {
    func setUnderline() {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count)
        )
        setAttributedTitle(attributedString, for: .normal)
    }
}
