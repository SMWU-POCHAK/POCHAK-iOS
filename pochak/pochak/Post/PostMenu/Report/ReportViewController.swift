//
//  ReportViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

enum ReportType: String {
    case NOT_INTERESTED
    case SPAM
    case NUDITY_OR_SEXUAL_CONTENT
    case FRAUD_OR_SCAM
    case HATE_SPEECH_OR_SYMBOL
    case MISINFORMATION
    
    static let reportReasons = [
        "마음에 들지 않습니다.",
        "스팸",
        "나체 이미지 또는 성적 행위",
        "사기 또는 거짓",
        "혐오 발언 또는 상징",
        "거짓 정보"
    ]
    
    /// 해당 인덱스의 report type 리턴
    static func getReportTypeAt(index: Int) -> ReportType {
        switch index {
        case 0:
            return NOT_INTERESTED
        case 1:
            return SPAM
        case 2:
            return NUDITY_OR_SEXUAL_CONTENT
        case 3:
            return FRAUD_OR_SCAM
        case 4:
            return HATE_SPEECH_OR_SYMBOL
        case 5:
            return MISINFORMATION
        default:
            return NOT_INTERESTED
        }
    }
    
    /// ReportType에 해당하는 사유 string 리턴
    static func getReasonForType(_ reportType: ReportType) -> String {
        switch reportType {
        case .NOT_INTERESTED:
            return reportReasons[0]
        case .SPAM:
            return reportReasons[1]
        case .NUDITY_OR_SEXUAL_CONTENT:
            return reportReasons[2]
        case .FRAUD_OR_SCAM:
            return reportReasons[3]
        case .HATE_SPEECH_OR_SYMBOL:
            return reportReasons[4]
        case .MISINFORMATION:
            return reportReasons[5]
        }
    }
    
    static func getReportTypeCount() -> Int {
        return reportReasons.count
    }
}

class ReportViewController: UIViewController {
    
    // MARK: - Properties

    private var postId: Int?

    // MARK: - Views
    
    @IBOutlet weak var reportTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTableView()
    }
    
    // MARK: - Functions
    
    private func setTableView() {
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.register(UINib(nibName: ReportTableViewCell.identifier, bundle: nil),
                                 forCellReuseIdentifier: ReportTableViewCell.identifier)
    }
    
    /// 게시글 신고 후 홈으로 돌아가기
    private func goBackToHome(){
        // 1. ReportVC를 보여주고 있는 뷰컨트롤러를 찾고 (=tabbar controller)
        if let tabBarController = self.presentingViewController as? UITabBarController,
           // 2. 선택된 뷰컨트롤러에 접근 (=navigation controller)
           let navigationController = tabBarController.selectedViewController as? UINavigationController {
            print(navigationController.viewControllers)
            // 3. 부모의 부모 뷰컨트롤러 (= home tab view controller)에 접근
            if let grandparentViewController = navigationController.viewControllers.dropLast().last {
                print(grandparentViewController)
                // 모달을 해제하고 그 후 네비게이션 스택에서 원하는 뷰컨트롤러로 이동
                self.dismiss(animated: true) {
                    navigationController.popToViewController(grandparentViewController, animated: true)
                }
            }
        }
    }
    
    private func failAlert(_ title: String){
        let alert = UIAlertController(title: title, message: "다시 시도해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
    }
    
    func setPostId(_ postId: Int){
        self.postId = postId
    }
}

// MARK: - Extension: UITableView

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportType.getReportTypeCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportTableViewCell.identifier, for: indexPath) as? ReportTableViewCell else { return UITableViewCell() }
        cell.configure(reportType: ReportType.getReportTypeAt(index: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ReportTableViewCell
        
        print("신고 사유: \(cell.reportType?.rawValue)")
        print("신고 게시물 아이디: \(postId)")
                
        PostDataService.shared.reportPost(postId: postId!, reportType: cell.reportType!) { [weak self] result in
            switch result {
            case .success(let data):
                print(data as! PostReportResponse)
                self?.showAlert(alertType: .confirmOnly,
                          titleText: "신고가 완료되었습니다.",
                          messageText: "신고해주셔서 감사합니다.\n빠른 시일 내에 해결하겠습니다.",
                          confirmButtonText: "확인")
                
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
                self?.failAlert("서버에 문제가 있습니다.")
            case .networkFail:
                print("networkFail")
                self?.failAlert("네트워크 연결에 문제가 있습니다.")
            }
        }
    }
    
}

extension ReportViewController: CustomAlertDelegate {
    func confirmAction() {
        goBackToHome()
    }
    
    func cancel() {
    }
}
