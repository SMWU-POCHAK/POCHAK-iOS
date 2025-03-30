//
//  TaggedUsersDetailViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/5/24.
//

import UIKit

final class TaggedUsersDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var tagList: [TaggedMember]?
    var goToOtherProfileVC: ((String) -> Void)?

    // MARK: - Views
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "태그"
        label.applyPochakFont(.body0)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.delegate = self
        view.separatorColor = UIColor(named: "gray01")
        view.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        view.allowsMultipleSelection = false
        view.allowsSelection = true
        view.rowHeight = 70
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addViews()
        setupConstraints()
        setTableView()
    }
        
    // MARK: - Funtions
    
    private func addViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(38)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TaggedUsersTableViewCell.self, forCellReuseIdentifier: TaggedUsersTableViewCell.identifier)
    }
}

// MARK: - Extension: UITableView

extension TaggedUsersDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaggedUsersTableViewCell.identifier, for: indexPath) as? TaggedUsersTableViewCell else { return UITableViewCell() }
        cell.configure(tagData: tagList![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        goToOtherProfileVC!(tagList![indexPath.row].handle)
    }
}
