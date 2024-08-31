//
//  SecondPostTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class SecondPostTabmanViewController: UIViewController {

    // MARK: - Data
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    var receivedHandle : String?
    var imageArray : [PostDataModel] = []
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate
        currentFetchingPage = 0
        // API
        loadImageData()

        // Collection View 구현
        setupCollectionView()
        
        // 새로고침 구현
        setRefreshControl()
    
    }
    
//    override func viewWillAppear(_ animated: Bool){
//        super.viewWillAppear(animated)
//        // Delegate
//        currentFetchingPage = 0
//        // API
//        loadImageData()
//    }

    // MARK: - Function
    
    private func setupCollectionView() {
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
            
        // collection view에 셀 등록
        postCollectionView.register(
            UINib(nibName: "ProfilePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfilePostCollectionViewCell")
        }
    
    private func loadImageData() {
        MyProfilePostDataManager.shared.myProfilePochakPostDataManager(receivedHandle ?? "",currentFetchingPage,{resultData in
            
            let newPosts = resultData.postList
            let startIndex = resultData.postList.count
            let endIndex = startIndex + newPosts.count
            let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
            self.imageArray.append(contentsOf: newPosts)
            self.isLastPage = resultData.pageInfo.lastPage
            
            DispatchQueue.main.async {
                if self.currentFetchingPage == 0 {
                    self.postCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                    print(">>>>>>> PochakPostDataManager is currently reloading!!!!!!!")
                } else {
                    self.postCollectionView.insertItems(at: newIndexPaths)
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
        postCollectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: Any) {
        // 데이터 새로고침 완료 후 UIRefreshControl을 종료
        print("refresh")
        self.imageArray = []
        self.currentFetchingPage = 0
        self.loadImageData()
        DispatchQueue.main.async {
            self.postCollectionView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Extension

extension SecondPostTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0,(imageArray.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell 생성
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfilePostCollectionViewCell.identifier,
            for: indexPath) as? ProfilePostCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let postData = imageArray[indexPath.item] // indexPath 안에는 섹션에 대한 정보, 섹션에 들어가는 데이터 정보 등이 있다
        cell.configure(postData)
        return cell
    }
    
    // cell 상하 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    // cell 옆 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    // cell 좌우 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat((collectionView.frame.width - 10) / 3)
        return CGSize(width: width, height: width * 4 / 3)
    }
    
    //  post 클릭 시 해당 post로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        postVC.receivedPostId = imageArray[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}

// Paging
extension SecondPostTabmanViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (postCollectionView.contentOffset.y > (postCollectionView.contentSize.height - postCollectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                loadImageData()
            }
        }
    }
}
