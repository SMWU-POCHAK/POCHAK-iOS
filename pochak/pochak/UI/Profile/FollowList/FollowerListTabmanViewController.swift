//
//  FollowerListTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

// cell 삭제 프로토콜
protocol RemoveImageDelegate: AnyObject {
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String)
}

final class FollowerListTabmanViewController: UIViewController {
    
    // MARK: - Properties
    
    var imageArray: [MemberListData] = []
    var receivedHandle: String?
    private var cellIndexPath: IndexPath?
    private var cellHandle: String?
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    private var loginUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
    
    // MARK: - Views
    
    @IBOutlet weak var followerCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentFetchingPage = 0
        setUpCollectionView()
        setUpRefreshControl()
        setUpData()
    }
    
    // MARK: - Actions
    
    @objc private func refreshData(_ sender: Any) {
        imageArray = []
        currentFetchingPage = 0
        setUpData()
        DispatchQueue.main.async() {
            self.followerCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private func setUpCollectionView() {
        followerCollectionView.delegate = self
        followerCollectionView.dataSource = self
        followerCollectionView.register(
            UINib(nibName: FollowerCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: FollowerCollectionViewCell.identifier)
    }
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        followerCollectionView.refreshControl = refreshControl
    }
    
    private func setUpData() {
        let request = FollowListRequest(page: currentFetchingPage)
        if let handle = receivedHandle {
            UserService.getFollowers(handle: handle, request: request) { [weak self] data, failed in
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
                
                let newMembers = data.result.memberList
                let startIndex = data.result.memberList.count
                let endIndex = startIndex + newMembers.count
                let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                self?.imageArray.append(contentsOf: newMembers)
                self?.isLastPage = data.result.pageInfo.lastPage
                
                DispatchQueue.main.async {
                    if self?.currentFetchingPage == 0 {
                        self?.followerCollectionView.reloadData()
                    } else {
                        self?.followerCollectionView.insertItems(at: newIndexPaths)
                    }
                    self?.isCurrentlyFetching = false
                    self?.currentFetchingPage += 1;
                }
            }
        } else {
            print("No handle received")
        }
    }
}

// MARK: - Extension: UICollectionViewDelegate, UICollectionViewDataSource

extension FollowerListTabmanViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FollowerCollectionViewCell.identifier,
            for: indexPath) as? FollowerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let memberListData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.searchedHandle = receivedHandle ?? ""
        cell.setUpCellData(memberListData)
        cell.delegate = self
        return cell
    }
    
    // 유저 클릭 시 해당 프로필로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let otherUserProfileVC = OtherUserProfileViewController()
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowerCollectionViewCell = self.followerCollectionView.cellForItem(at: indexPath)
                as? FollowerCollectionViewCell else { return }
        otherUserProfileVC.receivedHandle = cell.userId.text
    }
}

// MARK: - Extension: UICollectionViewDelegateFlowLayout

extension FollowerListTabmanViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followerCollectionView.bounds.width,
                      height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Extension: RemoveImageDelegate

extension FollowerListTabmanViewController: RemoveImageDelegate {
    
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String) {
        cellHandle = handle
        cellIndexPath = indexPath
        showAlert(alertType: .confirmAndCancel,
                  titleText: "팔로워를 삭제하시겠습니까?",
                  messageText: "팔로워를 삭제하면, 팔로워와 관련된 \n사진이 사라집니다.",
                  cancelButtonText: "취소",
                  confirmButtonText: "삭제하기")
    }
}

// MARK: - Extension: CustomAlertDelegate

extension FollowerListTabmanViewController: CustomAlertDelegate {
    
    func confirmAction() {
        let request = DeleteFollowerRequest(followerHandle: cellHandle ?? "")
        if let handle = receivedHandle {
            UserService.deleteFollower(handle: handle, request: request) { data, failed in
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
                self.imageArray.remove(at: self.cellIndexPath!.row)
                self.followerCollectionView.reloadData()
            }
        } else {
            print("No handle received")
        }
    }
    
    func cancel() {
        print("cancel button selected")
    }
}

// MARK: - Extension: UIScrollViewDelegate

extension FollowerListTabmanViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (followerCollectionView.contentOffset.y > (followerCollectionView.contentSize.height - followerCollectionView.bounds.size.height)) {
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setUpData()
            }
        }
    }
}
