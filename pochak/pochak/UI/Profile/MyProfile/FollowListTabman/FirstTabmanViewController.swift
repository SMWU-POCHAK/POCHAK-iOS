//
//  FirstTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

protocol RemoveImageDelegate: AnyObject {
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String)
}

class FirstTabmanViewController: UIViewController{
    // MARK: - Data
    
    @IBOutlet weak var followerCollectionView: UICollectionView!
    var imageArray : [MemberListDataModel] = []
    var recievedHandle : String?
    var cellIndexPath : IndexPath?
    var cellHandle : String?
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        currentFetchingPage = 0
        // API
        loadFollowerListData()
        // CollectionView 등록
        setupCollectionView()
        // 새로고침 구현
        setRefreshControl()
    }

    // MARK: - Method
    
    private func setupCollectionView() {
        followerCollectionView.delegate = self
        followerCollectionView.dataSource = self
            
        // collection view에 셀 등록
        followerCollectionView.register(
            UINib(nibName: "FollowerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FollowerCollectionViewCell")
        }

    private func loadFollowerListData() {
        FollowListDataManager.shared.followerDataManager(recievedHandle ?? "",currentFetchingPage,{resultData in
            
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
                    self.followerCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    print(">>>>>>> Follower is currently reloading!!!!!!!")
                } else {
                    self.followerCollectionView.insertItems(at: newIndexPaths)
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
        followerCollectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        print("refresh")
        self.imageArray = []
        self.currentFetchingPage = 0
        self.loadFollowerListData()
        DispatchQueue.main.async {
            self.followerCollectionView.refreshControl?.endRefreshing()
        }
    }
    
}

// MARK: - Extension

extension FirstTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell 생성
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FollowerCollectionViewCell.identifier,
            for: indexPath) as? FollowerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // 데이터 전달
        let memberListData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.configure(memberListData)
        
        // delegate 위임받음
        cell.delegate = self
        return cell
    }
    
    // 유저 클릭 시 해당 프로필로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let otherUserProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else {return}
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        guard let cell: FollowerCollectionViewCell = self.followerCollectionView.cellForItem(at: indexPath) as? FollowerCollectionViewCell else {return}
        otherUserProfileVC.recievedHandle = cell.userId.text
    }

}

extension FirstTabmanViewController : UICollectionViewDelegateFlowLayout{
    
    // cell 높이, 너비 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: followerCollectionView.bounds.width,
                      height: 70)
    }
    
    // cell 간 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
// cell 삭제 로직
extension FirstTabmanViewController: RemoveImageDelegate {
    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String) {
        print("inside removeCell")
        cellIndexPath = indexPath
        cellHandle = handle
        print(" >>>> cellIndexPath : \(cellIndexPath)")
        print(" >>>> cellHandle : \(cellHandle)")
        showAlert(alertType: .confirmAndCancel,
                  titleText: "팔로워를 삭제하시겠습니까?",
                  messageText: "팔로워를 삭제하면, 팔로워와 관련된 \n사진이 사라집니다.",
                  cancelButtonText: "취소",
                  confirmButtonText: "삭제하기"
        )
    }
}

extension FirstTabmanViewController : CustomAlertDelegate {
    func confirmAction() {
        // API
        DeleteFollowerDataManager.shared.deleteFollowerDataManager(self.recievedHandle ?? "", cellHandle ?? "", { resultData in
            print(resultData.message)
            // cell 삭제
            self.imageArray.remove(at: self.cellIndexPath!.row)
            self.followerCollectionView.reloadData()
        })
    }
    
    func cancel() {
        print("cancel button selected")
    }
}

//// cell 삭제 로직
//extension FirstTabmanViewController: RemoveImageDelegate {
//    func removeFromCollectionView(at indexPath: IndexPath, _ handle: String) {
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
//            DeleteFollowerDataManager.shared.deleteFollowerDataManager(self.recievedHandle ?? "", handle, { resultData in
//                print(resultData.message)
//            })
//            // cell 삭제
//            self.imageArray.remove(at: indexPath.row)
//            self.followerCollectionView.reloadData()
//        })
//        okAction.setValue(UIColor(named: "yellow00"), forKey: "titleTextColor")
//
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil) // present는 VC에서만 동작
//    }
//}

// Paging
extension FirstTabmanViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (followerCollectionView.contentOffset.y > (followerCollectionView.contentSize.height - followerCollectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                loadFollowerListData()
            }
        }
    }
}
