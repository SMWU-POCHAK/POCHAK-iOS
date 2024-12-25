//
//  MemoryViewController.swift
//  pochak
//
//  Created by Haru on 10/21/24.
//

import UIKit

class MemoryViewController: UIViewController {
    private let viewModel: MemoryViewModel
    
    init(viewModel: MemoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let profileStatsView = MemorySummaryView()
    private let pochakMomentsView = CarouselView()
    private let timelineView = TimelineView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "@\(viewModel.userID)님과 나의 순간들"
        setupUI()
        scrollView.delegate = self
        profileStatsView.delegate = self
        pochakMomentsView.delegate = self
        setupBindings()
        viewModel.loadMemoriesData()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .yellow02)
        
        title = "@\(viewModel.userID)님과 나의 순간들"
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    @objc private func handleTap() {
        let viewModel = MemoryGalleryViewModel(userID: viewModel.userID, type: .pochak)
        let summaryViewController = MemoryGalleryViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(summaryViewController, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .yellow02)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(profileStatsView)
        contentStackView.addArrangedSubview(pochakMomentsView)
        contentStackView.addArrangedSubview(timelineView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width - 40)
            $0.leading.trailing.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(40)
        }
        
        profileStatsView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0)
        }
        
        pochakMomentsView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0)
        }
        
        timelineView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    
    private func setupBindings() {
        viewModel.onMemorySummaryUpdated = { [weak self] memorySummary in
            guard let self = self else { return }
            self.profileStatsView.configure(with: memorySummary)
            self.pochakMomentsView.configure(memoryList: viewModel.converGalleryPostList(memorySummary: memorySummary))
            self.timelineView.configure(followPeriod: Date.formatDateRange(fromDateString: memorySummary.followDate),
                                        with: viewModel.timeLineEvent)
        }
    }
}

extension MemoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

extension MemoryViewController: CarouselViewDelegate {
    func didSelectMemoryPost(postID: Int) {
        let exploreTabSb = UIStoryboard(name: "ExploreTab", bundle: nil)
        guard let postVC = exploreTabSb.instantiateViewController(withIdentifier: "PostVC") as? PostViewController
        else { return }
        
        postVC.receivedPostId = postID
        self.navigationController?.pushViewController(postVC, animated: true)
    }
}

extension MemoryViewController: MemorySummaryViewDelegate {
    func didSelectMemoryCount(type: MemoryType) {
        let viewModel = MemoryGalleryViewModel(userID: viewModel.userID, type: type)
        let summaryViewController = MemoryGalleryViewController(viewModel: viewModel)
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}
