//
//  ReportTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

final class ReportTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ReportTableViewCell"
    
    var reportType: ReportType?

    // MARK: - Views
        
    private let reportReasonLabel: UILabel = {
        let label = UILabel()
        label.font = .Pretendard(size: 16, family: .Medium)
        label.setLineHeightByPx(value: 20)
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ChevronRight")
        return view
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    func configure(reportType: ReportType) {
        self.reportType = reportType
        self.reportReasonLabel.text = ReportType.getReasonForType(reportType)
    }
    
    private func addViews() {
        contentView.addSubview(reportReasonLabel)
        contentView.addSubview(arrowImageView)
    }
    
    private func setupConstraints() {
        reportReasonLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.bottom.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(12)
        }
    }
}
