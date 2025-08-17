//
//  PostListPageViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2/16/25.
//

import UIKit
import SnapKit

enum PostListType {
    case POCHAKED
    case POCHAK
}

final class PostListPageViewController: UIViewController {
    
    // MARK: - Properties
    
    let type: PostListType
    let myProfileTabVC: UIViewController
    let isMyProfile: Bool
    
    static private let minimumLineSpacing: CGFloat = 9
    static private let minimumInterItemSpacing: CGFloat = 8
    
    private var postList: [ProfilePostList] = []
    
    // MARK: - Views
    
    lazy var collectionView: AutoSizingCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = PostListPageViewController.minimumLineSpacing
        flowLayout.minimumInteritemSpacing = PostListPageViewController.minimumInterItemSpacing
        
        let view = AutoSizingCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.contentInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        view.dataSource = self
        view.delegate = self
        view.register(PostListCollectionViewCell.self, forCellWithReuseIdentifier: PostListCollectionViewCell.identifier)
        return view
    }()
    
    // MARK: - Init
    
    init(type: PostListType, parentVC: UIViewController, isMyProfile: Bool) {
        self.type = type
        self.isMyProfile = isMyProfile
        self.myProfileTabVC = parentVC

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setupConstraints()
    }
    
    // MARK: - Layout
    
    private func addViews() {
        view.addSubview(collectionView)
        view.backgroundColor = UIColor(named: "gray02")
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Functions
    
    func setPostCollectionViewData(_ postList: [ProfilePostList]) {
        if postList.isEmpty {  // 화면 refresh 한다는 의미
            print("[PostListPageViewController] setPostCollectionViewData, empty postlist")
            self.postList = []
            self.collectionView.reloadData()
            if isMyProfile {
                (self.myProfileTabVC as? MyProfileTabViewController)?.isCurrentlyFetching = false
            }
            else {
                (self.myProfileTabVC as? OtherUserProfileViewController)?.isCurrentlyFetching = false
            }
        }
        else {
            print("[PostListPageViewController] setPostCollectionViewData, \(type) NOT empty postlist")
            print("[PostListPageViewController] postList count: \(self.postList.count)")
            let startIndex = self.postList.count
            let endIndex = startIndex + postList.count
            let newIndexPathList = (startIndex ..< endIndex).map { IndexPath(item: $0, section: 0) }
            print("[PostListPageViewController] newIndexPathList: \(newIndexPathList)")
            
            self.collectionView.performBatchUpdates {
                self.postList.append(contentsOf: postList)
                self.collectionView.insertItems(at: newIndexPathList)
            } completion: { _ in /*[weak self] _ in*/
                if self.isMyProfile {
                    (self.myProfileTabVC as? MyProfileTabViewController)?.updateScrollViewContentSize()
                    (self.myProfileTabVC as? MyProfileTabViewController)?.isCurrentlyFetching = false
                }
                else {
                    (self.myProfileTabVC as? OtherUserProfileViewController)?.updateScrollViewContentSize()
                    (self.myProfileTabVC as? OtherUserProfileViewController)?.isCurrentlyFetching = false
                }
            }
        }
    }
}

// MARK: - Extension; UICollectionView

extension PostListPageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostListCollectionViewCell.identifier, for: indexPath) as? PostListCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: postList[indexPath.item].postImage)
        
        if indexPath.item == postList.count - 1 {
            if self.isMyProfile {
                (self.myProfileTabVC as? MyProfileTabViewController)?.updateScrollViewContentSize()
            }
            else {
                (self.myProfileTabVC as? OtherUserProfileViewController)?.updateScrollViewContentSize()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postVC = PostViewController()
        postVC.receivedPostId = postList[indexPath.item].postId
        self.myProfileTabVC.navigationController?.pushViewController(postVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.isMyProfile {
            (self.myProfileTabVC as? MyProfileTabViewController)?.updateScrollViewContentSize()
        }
        else {
            (self.myProfileTabVC as? OtherUserProfileViewController)?.updateScrollViewContentSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        return PostListPageViewController.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return PostListPageViewController.minimumInterItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat((collectionView.frame.width - 20 * 2 - PostListPageViewController.minimumInterItemSpacing * 2) / 3)  // 20은 양 끝 간격(inset)
        return CGSize(width: width, height: width * 4 / 3)  // 3:4 비율로
    }
}
