//
//  HomeTabViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/05.
//

import UIKit

final class HomeTabViewController: UIViewController {
    
    // MARK: - Properties
    
    private let minimumLineSpacing: CGFloat = 9
    private let minimumInterItemSpacing: CGFloat = 8

    private var postList: [HomeDataPostList]! = []
    private var isLastPage: Bool = false
    private var currentFetchingPage: Int = 0
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

        let request = HomeRequest(page: currentFetchingPage)
        HomeService.getHomePost(request: request) { data, failed in // weak self 넣기
            guard let data = data else { return print(failed?.localizedDescription) }
            print("succeed")
            print(data)
            self.isLastPage = data.result.pageInfo.lastPage

            let newPosts = data.result.postList
            let startIndex = self.postList.count
            let endIndex = startIndex + newPosts.count
            let newIndexPathList = (startIndex ..< endIndex).map { IndexPath(item: $0, section: 0) }

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
                    self.collectionView.insertItems(at: newIndexPathList)
                }

                self.isCurrentlyFetching = false
                self.currentFetchingPage += 1;
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
                cell.imageView.load(with: url)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !noPost {
            let postTabSb = UIStoryboard(name: "PostTab", bundle: nil)
            guard let postVC = postTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
            else { return }
            
            postVC.receivedPostId = postList[indexPath.item].postId
            self.navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return noPost ? 0 : minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return noPost ? 0 : minimumInterItemSpacing
    }
    
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
        if (!noPost && collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height)){
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
