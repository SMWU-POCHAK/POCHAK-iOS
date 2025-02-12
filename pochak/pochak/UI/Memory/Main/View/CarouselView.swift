//
//  CarouselView.swift
//  pochak
//
//  Created by MJ on 12/16/24.
//

import UIKit
import SnapKit

protocol CarouselViewDelegate: AnyObject {
    func didSelectMemoryPost(postID: Int)
}

class CarouselView: UIView {
    weak var delegate: CarouselViewDelegate?
    private let cellWidth: CGFloat = 145
    private let cellHeight: CGFloat = 145 * (4 / 3)
    private let cellSpacing: CGFloat = 10
    
    private var memoryList: [SummaryGalleryItem] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "POCHAK의 순간들"
        label.applyPochakFont(.body0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCarouselLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPage = 0
        control.pageIndicatorTintColor = UIColor(resource: .gray02)
        control.currentPageIndicatorTintColor = UIColor(resource: .yellow00)
        control.isHidden = true
        return control
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "처음 포착된 순간"
        label.applyPochakFont(.captionLarge)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(memoryList: [SummaryGalleryItem]) {
        self.memoryList = memoryList

        if memoryList.count > 2 {
            self.memoryList.insert(memoryList[memoryList.count-1], at: 0)
            self.memoryList.append(memoryList[0])
            self.pageControl.isHidden = false
            self.collectionView.isScrollEnabled = true
        } else if memoryList.count == 2 {
              self.memoryList.append(contentsOf: memoryList)
              self.pageControl.isHidden = false
              self.collectionView.isScrollEnabled = true

        } else {
            self.collectionView.isScrollEnabled = false
        }
        pageControl.numberOfPages = memoryList.count
        collectionView.reloadData()
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: memoryList.count > 2 ? 1 : 0, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 25
        
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(pageControl)
        addSubview(captionLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(32)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(193)
        }
        
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(19)
            make.centerX.equalToSuperview()
            make.height.equalTo(6)
            make.bottom.lessThanOrEqualToSuperview().offset(-18)
        }
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentHeight = max(collectionView.contentSize.height, 193)
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
        addGradientMask(to: collectionView)
    }
    
    private func addGradientMask(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.1, 0.9, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = view.bounds
        view.layer.mask = gradientLayer
        gradientLayer.frame = view.bounds
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension CarouselView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.identifier, for: indexPath) as? CarouselCell else {
            return UICollectionViewCell()
        }
        
        let item = memoryList[(indexPath.item % memoryList.count)]
        cell.configure(memory: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 145
        let height: CGFloat = width * 4/3
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = memoryList[indexPath.item]
        delegate?.didSelectMemoryPost(postID: selectedItem.post.id ?? 0)
    }
    
    private func createCarouselLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout {  [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(self.cellWidth),
                heightDimension: .absolute(self.cellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(self.cellWidth),
                heightDimension: .absolute(self.cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = self.cellSpacing
            
            if self.memoryList.count > 2 {
                self.setupCollectionViewCarousel(to: section)
            }
            
            return section
        }
    }
    
    private func setupCollectionViewCarousel(to section: NSCollectionLayoutSection) {
        section.visibleItemsInvalidationHandler = { visibleItems, offset, environment in
            let cellItems = visibleItems.filter {
                $0.representedElementKind != UICollectionView.elementKindSectionHeader
            }
            let containerWidth = environment.container.contentSize.width
            let collectionViewCenterX = offset.x + containerWidth / 2.0
            
            var closestPage = 0
            var minimumDistance: CGFloat = .greatestFiniteMagnitude
            
            
            cellItems.forEach { item in
                let itemCenterRelativeToOffset = item.frame.midX - offset.x
                let distanceFromCenter = abs(itemCenterRelativeToOffset - containerWidth / 2.0)
                
                if distanceFromCenter < minimumDistance {
                    minimumDistance = distanceFromCenter
                    closestPage = item.indexPath.item
                }
                
                let minScale: CGFloat = 0.9
                let maxScale: CGFloat = 1.0
                let scale = max(maxScale - (distanceFromCenter / containerWidth), minScale)
                
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
            let actualPage = closestPage - 1
            if actualPage >= 0 && actualPage < self.memoryList.count - 2 {
                self.pageControl.currentPage = actualPage
                self.captionLabel.text = self.memoryList[closestPage].type.description
            }
            
            if closestPage == self.memoryList.count - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0),
                                                     at: .centeredHorizontally,
                                                     animated: false)
                }
            } else if closestPage == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.collectionView.scrollToItem(at: IndexPath(item: self.memoryList.count - 2, section: 0),
                                                     at: .centeredHorizontally,
                                                     animated: false)
                }
            }
        }
    }
}

// MARK: - Carousel Cell
class CarouselCell: UICollectionViewCell {
    static let identifier = "CarouselCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(memory: SummaryGalleryItem) {
        if let url = URL(string: memory.post.imageURL ?? "") {
            imageView.load(with: url)
        }
    }
}
