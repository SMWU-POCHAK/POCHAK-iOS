//
//  BlockedUserViewController.swift
//  pochak
//
//  Created by Seo Cindy on 7/5/24.
//

import UIKit

protocol RemoveCellDelegate: AnyObject {
    func removeCell(at indexPath: IndexPath, _ handle: String)
}

class BlockedUserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var blockedUserList: [BlockedUserListDataModel] = []
    var cellIndexPath : IndexPath?
    var cellHandle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 네비게이션바 title 커스텀
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "차단관리"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        // cell 등록
        let nib  = UINib(nibName: BlockedUserTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)

        // 프로토콜 채택
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - Extension

extension BlockedUserViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension BlockedUserViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(0,(blockedUserList.count))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserTableViewCell.identifier, for: indexPath) as? BlockedUserTableViewCell else { return UITableViewCell() }
        
        cell.setData(blockedUserList[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

// cell 삭제 로직
extension BlockedUserViewController: RemoveCellDelegate {
    func removeCell(at indexPath: IndexPath, _ handle: String) {
        print("inside removeCell")
        cellIndexPath = indexPath
        cellHandle = handle
        print(" >>>> cellIndexPath : \(cellIndexPath)")
        print(" >>>> cellHandle : \(cellHandle)")
        showAlert(alertType: .confirmAndCancel,
                  titleText: "팔로워 차단을 취소하겠습니까?",
                  messageText: "팔로워 차단을 취소하면, 팔로워와 관련된 \n사진 및 소식을 다시 접할 수 있습니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
//        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
//        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 18), NSAttributedString.Key.foregroundColor: UIColor.black]
//        let titleString = NSAttributedString(string: "팔로워를 삭제하시겠습니까?", attributes: titleAttributes as [NSAttributedString.Key : Any])
//        
//        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Regular", size: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
//        let messageString = NSAttributedString(string: "\n팔로워를 삭제하면, 팔로워와 관련된 \n사진이 사라집니다.", attributes: messageAttributes as [NSAttributedString.Key : Any])
//        
//        alert.setValue(titleString, forKey: "attributedTitle")
//        alert.setValue(messageString, forKey: "attributedMessage")
//        
//        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
//        cancelAction.setValue(UIColor(named: "gray05"), forKey: "titleTextColor")
//        
//        let okAction = UIAlertAction(title: "삭제하기", style: .default, handler: {
//            action in
//            // API
//            
//            // cell 삭제
//            self.imageArray.remove(at: indexPath.row)
//            self.followerCollectionView.reloadData()
//        })
//        okAction.setValue(UIColor(named: "yellow00"), forKey: "titleTextColor")
//
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil) // present는 VC에서만 동작
    }
}

extension BlockedUserViewController : CustomAlertDelegate {
    func confirmAction() {
        let userHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
        // API
        UnBlockDataManager.shared.unBlockDataManager(userHandle ?? "" , cellHandle ?? "", { resultData in
            print(resultData.message)
        })
        // cell 삭제
        self.blockedUserList.remove(at: cellIndexPath?.row ?? 0)
        self.tableView.reloadData()
    }
    
    func cancel() {
        print("cancel button selected")
    }
}
