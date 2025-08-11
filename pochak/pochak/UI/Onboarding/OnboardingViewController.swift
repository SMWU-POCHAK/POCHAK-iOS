//
//  OnboardingViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/2/25.
//

import UIKit
import SnapKit

protocol OnboardingViewControllerDelegate: AnyObject {
    func didFinishOnboarding(_ onboardingVC: OnboardingViewController)
}

class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    
    weak var onboardingDelegate: OnboardingViewControllerDelegate?
    
    private var pages: [UIViewController] = []
    private var currentPage: Int = 0
    
    // MARK: - Views
    
    private let skipButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        let font = UIFont(name: "Pretendard-Regular", size: 13)
        config.attributedTitle = AttributedString("건너뛰기")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font : font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor.black]))
        config.contentInsets = .zero
        button.configuration = config
        button.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        let font = UIFont(name: "Pretendard-Bold", size: 16)
        config.attributedTitle = AttributedString("다음")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font : font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: "yellow00")]))
        config.contentInsets = .zero
        button.configuration = config
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(hexCode: "D9D9D9")
        pageControl.currentPageIndicatorTintColor = UIColor(named: "yellow00")
        pageControl.numberOfPages = 7
        pageControl.addTarget(self, action: #selector(didChangePageControl), for: .valueChanged)
        return pageControl
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        return vc
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        addViews()
        setupConstraints()
        setupPages()
        setupPageViewControllers()
    }
    
    // MARK: - Actions
    
    @objc private func didTapSkipButton() {
        onboardingDelegate?.didFinishOnboarding(self)
    }
    
    @objc private func didTapNextButton() {
        let nextPage = pageControl.currentPage + 1
        
        if nextPage == pages.count {
            onboardingDelegate?.didFinishOnboarding(self)
        }
        pageControl.currentPage = nextPage
        updatePageControl()
    }
    
    @objc private func didChangePageControl(_ sender: UIPageControl) {
        updatePageControl()
    }
    
    // MARK: - Functions
    
    private func addViews() {
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        view.addSubview(pageControl)
        view.addSubview(pageViewController.view)
    }
    
    private func setupConstraints() {
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10.adjustedH)
            make.leading.equalToSuperview().inset(28.adjusted)
        }
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(skipButton.snp.centerY)
            make.trailing.equalToSuperview().inset(28.adjusted)
        }
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom)//.offset(10.adjustedH)
            make.centerX.equalToSuperview()
        }
        pageViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(pageControl.snp.bottom).offset(23.adjustedH)
        }
    }
    
    private func setupPages() {
        let page1 = OnboardingPageViewController(imageName: "Onboarding1",
                                                 title: "친구들의 일상을 확인해요",
                                                 subtitle: "내 친구의 소식을 보며\n댓글을 달아요")
        let page2 = OnboardingPageViewController(imageName: "Onboarding2",
                                                 title: "순간을 포착하세요!",
                                                 subtitle: "후면 카메라를 통해\n친구의 자연스러운 순간을 포착해요")
        let page3 = OnboardingPageViewController(imageName: "Onboarding3",
                                                 title: "포착한 추억을 공유하세요",
                                                 subtitle: "포착한 친구들을 태그해 업로드해서\n모든 친구들이 수락하면 피드에 올라가요")
        let page4 = OnboardingPageViewController(imageName: "Onboarding4",
                                                 title: "게시물을 미리 확인해요",
                                                 subtitle: "내 피드에 올라올 게시물을\n미리 확인하고, 수락할 수 있어요")
        let page5 = OnboardingPageViewController(imageName: "Onboarding5",
                                                 title: "소중한 순간들을 모아볼까요?",
                                                 subtitle: "내가 포착된 피드와 포착한 피드를\n한눈에 확인할 수 있어요")
        let page6 = OnboardingPageViewController(imageName: "Onboarding6",
                                                 title: "함께한 순간을 한눈에 확인해요",
                                                 subtitle: "친구와 함께한 포착의 순간들을\n추억할 수 있어요")
        let page7 = OnboardingPageViewController(imageName: "Onboarding7",
                                                 title: "내 주위 포차커를 탐색해요",
                                                 subtitle: "주변에 있는 포착 친구를 찾고,\n바로 포착할 수 있어요")
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        pages.append(page4)
        pages.append(page5)
        pages.append(page6)
        pages.append(page7)
    }
    
    private func setupPageViewControllers() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        pageViewController.setViewControllers([pages[currentPage]], direction: .forward, animated: true)
    }
    
    private func updatePageControl() {
        guard let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else { return }
                
        // 코드의 순서 상 페이지의 인덱스보다 pageControl의 값이 먼저 변한다.
        // 그러므로, currentPage가 크면 오른쪽 방향, 작으면 왼쪽 방향으로 움직이게 설정해 줌
        let direction: UIPageViewController.NavigationDirection = (pageControl.currentPage > currentIndex) ? .forward : .reverse
        pageViewController.setViewControllers([pages[pageControl.currentPage]], direction: direction, animated: true)
        
        // 마지막 페이지인 경우 '다음'을 '시작하기'로 변경
        if pageControl.currentPage == pages.count - 1 {
            changeNextButtonTitle(to: "시작하기")
        }
        else {
            changeNextButtonTitle(to: "다음")
        }
    }
    
    private func changeNextButtonTitle(to title: String) {
        let font = UIFont(name: "Pretendard-Bold", size: 16)
        nextButton.configuration?.attributedTitle = AttributedString(title)
        nextButton.configuration?.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font : font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: "yellow00")]))
        nextButton.configuration?.contentInsets = .zero
    }

}

// MARK: - Extensions; PageViewController

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        guard currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
                
        guard currentIndex < (pages.count - 1) else { return nil }
        return pages[currentIndex + 1]
    }
    
    // page가 다 넘어가면 pageControl 값 변경
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers,
              let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }

        pageControl.currentPage = currentIndex
        updatePageControl()
    }
}
