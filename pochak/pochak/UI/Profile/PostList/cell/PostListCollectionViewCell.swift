//
//  PostListCollectionViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2/16/25.
//

import UIKit

final class PostListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "PostListCollectionViewCell"
    
    // MARK: - Views
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .black
        contentView.backgroundColor = .blue
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func addViews() {
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Functions
    
    func configure(with imageUrlStr: String) {
        if let url = URL(string: imageUrlStr) {
            imageView.load(with: url)
        }
    }
}
