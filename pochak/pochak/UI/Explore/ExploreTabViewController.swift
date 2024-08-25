//
//  ExploreTabViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/04.
//

import UIKit
import Kingfisher

final class ExploreTabViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    private var ExploreTabDataResponse: ExploreResponse!
    private var ExploreTabDataResult: ExploreDataResult!
    private var postList: [ExploreDataPostList]! = []
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    // MARK: - Views
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentFetchingPage = 0
        
        setupCollectionView()
        setupData()
        setSearchBarView()
        setupTapGestureOnSearchBarView()
        setRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func searchBarViewTapped() {
        // 최근 검색어 화면으로 전환
        let storyboard = UIStoryboard(name: "ExploreTab", bundle: nil)
        if let recentSearchVC = storyboard.instantiateViewController(withIdentifier: "RecentSearchVC") as? RecentSearchViewController {
            self.navigationController?.pushViewController(recentSearchVC, animated: false)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        self.postList = []
        self.currentFetchingPage = 0
        self.setupData()
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(
            nibName: PostCollectionViewCell.identifier,
            bundle: nil),forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
    }
    
    private func setupData() {
        isCurrentlyFetching = true
        
        let request = ExploreRequest(page: currentFetchingPage)
        ExploreService.getExploreTab(request: request) { [weak self] data, failed in
            guard let data = data else {
                // 에러가 난 경우, alert 창 present
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
            
            print("=== ExploreTab data succeeded ===")
            print("== data: \(data)")
            
            self?.ExploreTabDataResponse = data
            guard let result = self?.ExploreTabDataResponse?.result else { return }

            let newPosts = result.postList
            let startIndex = self?.postList.count
            let endIndex = startIndex! + newPosts.count
            let newIndexPaths = (startIndex! ..< endIndex).map { IndexPath(item: $0, section: 0) }

            self?.postList.append(contentsOf: newPosts)
            self?.isLastPage = result.pageInfo.lastPage

            DispatchQueue.main.async {
                if self?.currentFetchingPage == 0 {
                    self?.collectionView.reloadData()
                }
                else {
                    self?.collectionView.insertItems(at: newIndexPaths)
                }
                self?.isCurrentlyFetching = false
                self?.currentFetchingPage += 1;
            }
        }
    }
    
    private func setSearchBarView() {
        self.searchBarView.layer.cornerRadius = 7
        self.searchBarView.clipsToBounds = true
    }
    
    private func setupTapGestureOnSearchBarView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchBarViewTapped))
        searchBarView.addGestureRecognizer(tapGesture)
    }
    
    private func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
    }
}

// MARK: - Extension: UICollectionView

extension ExploreTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
            fatalError("셀 타입 캐스팅 실패")
        }
        
        if !postList.isEmpty {
            if let url = URL(string: postList[indexPath.item].postImage) {
                cell.imageView.load(with: url)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
        else { return }
        
        postVC.receivedPostId = postList[indexPath.item].postId
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4.5, left: 20, bottom: 4.5, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 56) / 3
        let height = width * 4 / 3
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Extension: UIScrollView

extension ExploreTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height)) {
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                setupData()
            }
        }
    }
}
