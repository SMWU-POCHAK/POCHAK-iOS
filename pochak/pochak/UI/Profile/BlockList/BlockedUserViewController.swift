//
//  BlockedUserViewController.swift
//  pochak
//
//  Created by Seo Cindy on 7/5/24.
//

import UIKit

// cell 삭제 protocol
protocol RemoveCellDelegate: AnyObject {
    func removeCell(at indexPath: IndexPath, _ handle: String)
}

class BlockedUserViewController: UIViewController {
    
    // MARK: - Properties
    var blockedUserList: [BlockList] = []
    var cellIndexPath: IndexPath?
    var cellHandle: String?
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - Views
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentFetchingPage = 0
        
        setUpNavigationBar()
        setUpTableView()
        setUpRefreshControl()
        setUpData()
    }
    
    // MARK: - Actions
    
    @objc private func refreshData(_ sender: Any) {
        blockedUserList = []
        currentFetchingPage = 0
        setUpData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private func setUpNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "차단관리"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
    }
    
    private func setUpTableView() {
        let nib  = UINib(nibName: BlockedUserTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setUpData() {
        isCurrentlyFetching = true
        let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
        let request = BlockListRequest(page: currentFetchingPage)
        
        UserService.getBlockUserList(handle: handle, request: request) { data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            let newBlockedUsers = data.result.blockList
            let startIndex = data.result.blockList.count
            let endIndex = startIndex + newBlockedUsers.count
            let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
            self.blockedUserList.append(contentsOf: newBlockedUsers)
            self.isLastPage = data.result.pageInfo.lastPage
            
            DispatchQueue.main.async {
                if self.currentFetchingPage == 0 {
                    self.tableView.reloadData()
                } else {
                    self.tableView.insertRows(at: newIndexPaths, with: .none)
                }
                self.isCurrentlyFetching = false
                self.currentFetchingPage += 1;
            }
        }
    }
}

// MARK: - Extension : UITableViewDelegate, UITableViewDataSource, RemoveCellDelegate, CustomAlertDelegate, UIScrollViewDelegate

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
        cell.setUpCellData(blockedUserList[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

extension BlockedUserViewController: RemoveCellDelegate {
    
    func removeCell(at indexPath: IndexPath, _ handle: String) {
        cellHandle = handle
        cellIndexPath = indexPath
        showAlert(alertType: .confirmAndCancel,
                  titleText: "유저 차단을 취소하겠습니까?",
                  messageText: "유저 차단을 취소하면, 팔로워와 관련된 \n사진 및 소식을 다시 접할 수 있습니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
    }
}

extension BlockedUserViewController: CustomAlertDelegate {
    
    func confirmAction() {
        let userHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
        let request = UnblockRequest(blockedMemberHandle: cellHandle ?? "")
        UserService.unblockUser(handle: userHandle, request: request) { data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            self.blockedUserList.remove(at: self.cellIndexPath!.row)
            self.tableView.reloadData()
        }
    }
    
    func cancel() {
        print("cancel button selected")
    }
}

extension BlockedUserViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tableView.contentOffset.y > (tableView.contentSize.height - tableView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setUpData()
            }
        }
    }
}
