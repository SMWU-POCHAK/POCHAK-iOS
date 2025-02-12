//
//  MemoryGalleryViewController.swift
//  pochak
//
//  Created by Haru on 12/9/24.
//

import Foundation
import UIKit
import SnapKit

enum MemoryType: String {
    case pochak = "FirstPochak"
    case bonded = "FirstBonded"
    case pochaked = "FirstPochaked"
    case latestPost = "LatestPost"
    case post1YearAgo = "Post1YearAgo"
    
    var description: String {
        switch self {
        case .pochak:
            "처음 포착한 순간"
        case .bonded:
            "처음 함께 포착된 순간"
        case .pochaked:
            "처음 포착된 순간"
        case .latestPost:
            "최근 포스트"
        case .post1YearAgo:
            "1년 전 포스트"
        }
    }
    
    var title: String {
        switch self {
        case .pochak:
            return "POCHAK"
        case .bonded:
            return "BONDED"
        case .pochaked:
            return "POCHAKED"
        default:
            return ""
        }
    }
}

class MemoryGalleryViewController: UIViewController {
    private let viewModel: MemoryGalleryViewModel
    
    init(viewModel: MemoryGalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "POCHAKED BY @bbaek"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 56) / 3, height: 144)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 22)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderReusableView.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setupViews()
        setupConstraints()
        setupCollectionView()
        setupBindings()
        viewModel.loadMemoriesData()
    }
    
    private func setTitle() {
        switch viewModel.type {
        case .pochak:
            title = "POCHAK BY @\(viewModel.userID)"
        case .pochaked:
            title = "POCHAKED BY @\(viewModel.userID)"
        case .bonded:
            title = "BONDED WITH @\(viewModel.userID)"
        default:
            title = ""
        }
    }
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.onPostListUpdated = { [weak self] sectionList in
            guard let self = self else { return }
            collectionView.reloadData()
        }
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension MemoryGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.memorySectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < viewModel.memorySectionList.count else { return 0 }
        return viewModel.memorySectionList[section].posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let sction = viewModel.memorySectionList[indexPath.section]
        let post = sction.posts[indexPath.item]
        
        cell.configure(with: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.identifier, for: indexPath) as! HeaderReusableView
            let section = viewModel.memorySectionList[indexPath.section]
            header.configure(with: section.yearMonth)
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = viewModel.memorySectionList[indexPath.section]
        let selectedPost = section.posts[indexPath.item]
        
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
        else { return }
        
        postVC.receivedPostId = selectedPost.id
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}
