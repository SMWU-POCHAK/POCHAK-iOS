//
//  FollowingListTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

final class FollowingListTabmanViewController: UIViewController {
    
    // MARK: - Properties
    
    var imageArray: [MemberListData] = []
    var receivedHandle: String?
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - Views
    
    @IBOutlet weak var followingCollectionView: UICollectionView!
    
    // MARK: - LifeCycle
    
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
            self.followingCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private func setUpCollectionView() {
        followingCollectionView.delegate = self
        followingCollectionView.dataSource = self
        followingCollectionView.register(
            UINib(nibName: FollowingCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: FollowingCollectionViewCell.identifier)
    }
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        followingCollectionView.refreshControl = refreshControl
    }
    
    private func setUpData() {
        let request = FollowListRequest(page: currentFetchingPage)
        if let handle = receivedHandle {
            UserService.getFollowings(handle: handle, request: request) { [weak self] data, failed in
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
                        self?.followingCollectionView.reloadData()
                    } else {
                        self?.followingCollectionView.insertItems(at: newIndexPaths)
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

extension FollowingListTabmanViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FollowingCollectionViewCell.identifier,
            for: indexPath) as? FollowingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let memberListData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.setUpCellData(memberListData)
        return cell
    }
    
    // 유저 클릭 시 해당 프로필로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let otherUserProfileVC = OtherUserProfileViewController()
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowingCollectionViewCell = self.followingCollectionView.cellForItem(at: indexPath)
                as? FollowingCollectionViewCell else { return }
        otherUserProfileVC.receivedHandle = cell.userId.text
    }
}

// MARK: - Extension: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension FollowingListTabmanViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followingCollectionView.bounds.width,
                      height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Extension: UIScrollViewDelegate

extension FollowingListTabmanViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (followingCollectionView.contentOffset.y > (followingCollectionView.contentSize.height - followingCollectionView.bounds.size.height)) {
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setUpData()
            }
        }
    }
}
