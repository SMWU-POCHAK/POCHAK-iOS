//
//  HomeTabViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/05.
//

import UIKit

class HomeTabViewController: UIViewController {
    
    // MARK: - Properties

    private var postList: [HomeDataPostList]! = []
    private var isLastPage: Bool = false
    private var currentFetchingPage: Int = 0
    private var homeDataResponse: HomeDataResponse!
    private var homeDataResult: HomeDataResult!
    
    private let minimumLineSpacing: CGFloat = 9
    private let minimumInterItemSpacing: CGFloat = 8
    private var noPost: Bool = false
    private var isCurrentlyFetching: Bool = false
    
    private var refreshControl = UIRefreshControl()
    
    // MARK: - Views
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        print("view will load - home")
        super.viewDidLoad()
        
        currentFetchingPage = 0
        setupData()
        
        setupNavigationBar()
        setupCollectionView()
        
        refreshControl.addTarget(self, action: #selector(refreshHome), for: .valueChanged)
        refreshControl.tintColor = UIColor(named: "navy02")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear - home")
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Actions
    
    @objc func refreshHome() {
        self.currentFetchingPage = 0
        self.postList.removeAll()
        self.setupData()
    }
    
    // MARK: - Functions
    
    private func setupNavigationBar() {
        let logoImageView = UIImageView(image: UIImage(named: "logo_full"))
        logoImageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logoImageView
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.refreshControl = refreshControl
            
        collectionView.register(
            UINib(nibName: HomeCollectionViewCell.identifier, bundle: nil), 
            forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        
        collectionView.register(
            UINib(nibName: NoPostCollectionViewCell.identifier, bundle: nil), 
            forCellWithReuseIdentifier: NoPostCollectionViewCell.identifier)
    }
    
    private func setupData() {
        isCurrentlyFetching = true
        // 임시로 유저 핸들 지수로
        HomeDataService.shared.getHomeData(page: currentFetchingPage) { response in
            switch response {
            case .success(let data):
                self.homeDataResponse = data
                self.homeDataResult = self.homeDataResponse.result
                
                self.isLastPage = self.homeDataResult.pageInfo.lastPage

                let newPosts = self.homeDataResult.postList
                let startIndex = self.postList.count
                let endIndex = startIndex + newPosts.count
                let newIndexPath = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                
                self.postList.append(contentsOf: newPosts)
                
                if self.postList.count == 0 {
                    self.noPost = true
                }
                else {
                    self.noPost = false
                }
                
                print("보여주는 게시글 개수: \(self.postList.count)")
                DispatchQueue.main.async {
                    if self.currentFetchingPage == 0 {
                        self.collectionView.reloadData()
                    } 
                    else {
                        self.collectionView.insertItems(at: newIndexPath)
                    }
                    
                    self.isCurrentlyFetching = false
                    self.currentFetchingPage += 1;
                }
            case .requestErr(let err):
                print(err)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
                self.present(UIAlertController.networkErrorAlert(title: "서버에 문제가 있습니다."), animated: true)
            case .networkFail:
                print("networkFail")
                self.present(UIAlertController.networkErrorAlert(title: "네트워크 연결에 문제가 있습니다."), animated: true)
            }
        }
    }
}

// MARK: - Extension: CollectionView

extension HomeTabViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noPost ? 1 : postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if noPost {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoPostCollectionViewCell.identifier, for: indexPath) as? NoPostCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell
            else{ return UICollectionViewCell() }
            
            if let url = URL(string: (self.postList[indexPath.item].postImage)) {
                cell.imageView.load(url: url)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !noPost {
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.parentVC = self
            postVC.receivedPostId = postList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    // cell의 위 아래 간격을 정함
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return noPost ? 0 : minimumLineSpacing
    }
    
    // cell 양 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return noPost ? 0 : minimumInterItemSpacing
    }
    
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if noPost {
            let mainBound = UIScreen.main.bounds.size
            let width = mainBound.width
            let height = self.collectionView.bounds.height
            return CGSize(width: width, height: height)
        }
        else {
            let width = CGFloat((collectionView.frame.width - 20 * 2 - minimumInterItemSpacing * 2) / 3)  // 20은 양 끝 간격
            return CGSize(width: width, height: width * 4 / 3)  // 3:4 비율로
        }
    }
}

// MARK: - Extension: UIScrollView

extension HomeTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!noPost && collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height)) {
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setupData()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
             refreshControl.endRefreshing()
        }
    }
}
