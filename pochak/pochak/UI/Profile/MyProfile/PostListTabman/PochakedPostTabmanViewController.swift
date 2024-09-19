//
//  FirstPostTabmanViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class PochakedPostTabmanViewController: UIViewController {
    
    // MARK: - Properties
    
    var receivedHandle: String?
    var imageArray: [PostDataModel] = []
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - Views
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
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
        print("refresh")
        imageArray = []
        currentFetchingPage = 0
        setUpData()
        DispatchQueue.main.async {
            self.postCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private func setUpCollectionView() {
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        postCollectionView.register(
            UINib(nibName: ProfilePostCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identifier)
    }
    
    private func setUpRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        postCollectionView.refreshControl = refreshControl
    }
    
    private func setUpData() {
        isCurrentlyFetching = true
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(receivedHandle ?? "", currentFetchingPage, { response in
            switch response {
            case .success(let resultData):
                
                let newPosts = resultData.postList
                let startIndex = resultData.postList.count
                print("startIndex : \(startIndex)")
                let endIndex = startIndex + newPosts.count
                print("endIndex : \(endIndex)")
                let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                print("newIndexPaths : \(newIndexPaths)")
                self.imageArray.append(contentsOf: newPosts)
                self.isLastPage = resultData.pageInfo.lastPage
                
                print("보여주는 게시글 개수: \(newPosts.count)")
                DispatchQueue.main.async {
                    if self.currentFetchingPage == 0 {
                        self.postCollectionView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
                        print(">>>>>>> PochakedPostDataManager is currently reloading!!!!!!!")
                    } else {
                        self.postCollectionView.insertItems(at: newIndexPaths)
                        print(">>>>>>> PochakedPostDataManager is currently fethcing!!!!!!!")
                    }
                    self.isCurrentlyFetching = false
                    self.currentFetchingPage += 1;
                }
            case .MEMBER4002:
                print("유효하지 않은 멤버의 handle입니다.")
            }
        })
    }
}

// MARK: - Extension : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate

extension PochakedPostTabmanViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        cell.setUpCellData(postData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat((collectionView.frame.width - 10) / 3)
        return CGSize(width: width, height: width * 4 / 3)
    }
    
    // post 클릭 시 해당 post로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
        postVC.receivedPostId = imageArray[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}

extension PochakedPostTabmanViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (postCollectionView.contentOffset.y > (postCollectionView.contentSize.height - postCollectionView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setUpData()
            }
        }
    }
}
