//
//  SecondTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class SecondTabmanViewController: UIViewController {
    
    // MARK: - Data

    @IBOutlet weak var followingCollectionView: UICollectionView!
    var imageArray : [MemberListDataModel] = []
    var recievedHandle : String?
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        currentFetchingPage = 0
        // API
        loadFollowingListData()
        // CollectionView 등록
        setupCollectionView()
        // 새로고침 구현
        setRefreshControl()
    }
    
    // MARK: - Method

    private func setupCollectionView() {
        followingCollectionView.delegate = self
        followingCollectionView.dataSource = self
            
        // collection view에 셀 등록
        followingCollectionView.register(
            UINib(nibName: "FollowingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FollowingCollectionViewCell")
        }
    
    private func loadFollowingListData() {
        FollowListDataManager.shared.followingDataManager(recievedHandle ?? "",currentFetchingPage, {resultData in
            let newMembers = resultData.memberList
            let startIndex = resultData.memberList.count
            print("startIndex : \(startIndex)")
            let endIndex = startIndex + newMembers.count
            print("endIndex : \(endIndex)")
            let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
            print("newIndexPaths : \(newIndexPaths)")
            self.imageArray.append(contentsOf: newMembers)
            self.isLastPage = resultData.pageInfo.lastPage
            
            print("보여주는 계정 개수: \(newMembers.count)")
            DispatchQueue.main.async {
                if self.currentFetchingPage == 0 {
                    self.followingCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    print(">>>>>>> Follower is currently reloading!!!!!!!")
                } else {
                    self.followingCollectionView.insertItems(at: newIndexPaths)
                    print(">>>>>>> Follower is currently fethcing!!!!!!!")
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
        followingCollectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        print("refresh")
        self.imageArray = []
        self.currentFetchingPage = 0
        self.loadFollowingListData()
        DispatchQueue.main.async {
            self.followingCollectionView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Extension

extension SecondTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell 생성
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FollowingCollectionViewCell.identifier,
            for: indexPath) as? FollowingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // 데이터 전달
        let memberListData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.configure(memberListData)
        return cell
    }
    
    //  유저 클릭 시 해당 프로필로 이동
    // 프로필 클릭 시에도 이동하도록
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else {return}
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowingCollectionViewCell = self.followingCollectionView.cellForItem(at: indexPath) as? FollowingCollectionViewCell else {return}
        otherUserProfileVC.recievedHandle = cell.userId.text
    }
}

extension SecondTabmanViewController : UICollectionViewDelegateFlowLayout{
    // cell 높이, 너비 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followingCollectionView.bounds.width,
                      height: 70)
    }
    
    // cell 간 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// Paging
extension SecondTabmanViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (followingCollectionView.contentOffset.y > (followingCollectionView.contentSize.height - followingCollectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                loadFollowingListData()
            }
        }
    }
}
