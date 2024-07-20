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
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 네비게이션바 title 커스텀
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "차단관리"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        // Delegate
        currentFetchingPage = 0
        // API
        loadBlockedUserList()
    
        // cell 등록
        let nib  = UINib(nibName: BlockedUserTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)

        // 프로토콜 채택
        tableView.delegate = self
        tableView.dataSource = self
        
        // 새로고침 구현
        setRefreshControl()
    }
    
    private func loadBlockedUserList(){
        let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
        isCurrentlyFetching = true
        BlockedUserListDataManager.shared.blockedUserListDataManager(handle, currentFetchingPage, { resultData in
            let newBlockedUsers = resultData.blockList
            let startIndex = resultData.blockList.count
            let endIndex = startIndex + newBlockedUsers.count
            let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
            self.blockedUserList.append(contentsOf: newBlockedUsers)
            self.isLastPage = resultData.pageInfo.lastPage
            
            DispatchQueue.main.async {
                if self.currentFetchingPage == 0 {
                    self.tableView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    print(">>>>>>> PochakPostDataManager is currently reloading!!!!!!!")
                } else {
                    self.tableView.insertRows(at: newIndexPaths, with: .none)
                    print(">>>>>>> PochakPostDataManager is currently insertingRows!!!!!!!")
                }
                self.isCurrentlyFetching = false
                self.currentFetchingPage += 1;
            }
        })
    }
    private func setRefreshControl(){
        // UIRefreshControl 생성
       let refreshControl = UIRefreshControl()
       refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

       // 테이블 뷰에 UIRefreshControl 설정
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        print("refresh")
        self.blockedUserList = []
        self.currentFetchingPage = 0
        self.loadBlockedUserList()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
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
                  titleText: "유저 차단을 취소하겠습니까?",
                  messageText: "유저 차단을 취소하면, 팔로워와 관련된 \n사진 및 소식을 다시 접할 수 있습니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
    }
}

extension BlockedUserViewController : CustomAlertDelegate {
    func confirmAction() {
        let userHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
        // API
        UnBlockDataManager.shared.unBlockDataManager(userHandle ?? "" , cellHandle ?? "", { resultData in
            print(resultData.message)
            // cell 삭제
            self.blockedUserList.remove(at: self.cellIndexPath!.row)
            self.tableView.reloadData()
        })
    }
    
    func cancel() {
        print("cancel button selected")
    }
}

// Paging
extension BlockedUserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tableView.contentOffset.y > (tableView.contentSize.height - tableView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                loadBlockedUserList()
            }
        }
    }
}
