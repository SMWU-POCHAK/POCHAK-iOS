//
//  SearchResultViewController.swift
//  pochak
//
//  Created by 장나리 on 12/27/23.
//

import Foundation
import UIKit
import RealmSwift

final class RecentSearchViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    private var searchTextField = UITextField()
    private var cancelButton = UIButton()
    private var resultVC = UITableViewController()
    
    private var realmManager = RecentSearchRealmManager()
    private var recentSearchTerms: Results<RecentSearchModel>!
    
    private var idSearchResponseData: IdSearchResponse!
    private var memberList: [IdSearchMember]! = []
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0
    
    private var currentText : String = ""
    private var searchTextFieldWidthConstraint: NSLayoutConstraint!
    private var cancelButtonLeadingConstraint: NSLayoutConstraint!
    
    
    // MARK: - Views
    
    @IBOutlet weak var deleteAllButton: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("==RecentSearchViewController==")
        
        deleteAllBtnAction()
        setupSearchTextField()
        setupResultViewController()
        setupResultViewLayout()
        setupTableView()
        loadRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.cancelButton.isHidden = true
        setupResultViewLayout()
    }
    
    // MARK: - Actions
    
    @objc func deleteAllTapped() {
        if realmManager.deleteAllData() {
            recentSearchTerms = realmManager.getAllRecentSearchTerms()
            tableView.reloadData()
        } else {
            print("Failed to delete all data")
        }
    }
    
    @objc func didTextFieldChanged() {
        currentText = self.searchTextField.text ?? ""
        self.memberList = []
        self.currentFetchingPage = 0
        
        if currentText.isEmpty {
            self.resultVC.tableView.isHidden = true
            self.resultVC.tableView.reloadData()
        } else {
            self.resultVC.tableView.isHidden = false
            print(currentText)
            sendTextToServer(currentText)
            tableView.reloadData()
        }
    }
    
    @objc private func cancelButtonClicked() {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        resultVC.view.isHidden = true
        loadRealm()
    }
    
    // MARK: - Functions
    
    private func deleteAllBtnAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteAllTapped))
        deleteAllButton.isUserInteractionEnabled = true
        deleteAllButton.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.placeholder = "검색어를 입력해주세요."
        searchTextField.font = UIFont(name: "Pretendard-Medium", size: 16)
        searchTextField.backgroundColor = UIColor(named: "gray0.5")
        searchTextField.layer.cornerRadius = 7
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.clearButtonMode = .never
        searchTextField.returnKeyType = .search
        searchTextField.setPlaceholderColor(UIColor(named: "gray03"), font: "Pretendard-Medium", fontSize: 16)
        searchTextField.tintColor = .black
        searchTextField.addTarget(self, action: #selector(didTextFieldChanged), for: .editingChanged)
        
        let iconView = UIImageView(frame: CGRect(x: 12, y: 12, width: 24, height: 24))
        iconView.image = UIImage(named: "search")
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        iconContainerView.addSubview(iconView)
        
        searchTextField.leftView = iconContainerView
        searchTextField.leftViewMode = .always
        
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let searchContainerView = searchContainerView {
            searchContainerView.addSubview(searchTextField)
            searchContainerView.addSubview(cancelButton)
            
            NSLayoutConstraint.activate([
                searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
                searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
                searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
                searchTextField.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor)
            ])
            
            let textFieldHeightConstraint = searchTextField.heightAnchor.constraint(equalToConstant: searchContainerView.frame.height)
            textFieldHeightConstraint.isActive = true
            
            searchTextFieldWidthConstraint = searchTextField.widthAnchor.constraint(equalToConstant: self.searchContainerView.frame.width)
            searchTextFieldWidthConstraint.isActive = true

            NSLayoutConstraint.activate([
                cancelButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 10),
                cancelButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
                cancelButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor)
            ])
            
            let cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalTo: searchContainerView.heightAnchor)
            cancelButtonHeightConstraint.isActive = true
            
            cancelButtonLeadingConstraint = cancelButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor)
            cancelButtonLeadingConstraint.constant = searchContainerView.frame.width
            cancelButtonLeadingConstraint.constant = 0
            cancelButtonLeadingConstraint.isActive = true
            
            self.cancelButton.isHidden = true
        }
    }
    
    private func setupResultViewController() {
        // 검색 결과 tableViewController 설정
        resultVC = UITableViewController()
        resultVC.tableView.delegate = self
        resultVC.tableView.dataSource = self
        resultVC.tableView.separatorStyle = .none
        resultVC.tableView.register(UINib(nibName: SearchResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        
        resultVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultVC.view)
        
        resultVC.view.isHidden = true
    }
    
    private func setupResultViewLayout() {
        NSLayoutConstraint.activate([
            resultVC.view.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 16),
            resultVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            resultVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            resultVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: SearchResultTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchResultTableViewCell.identifier)
    }
    
    func loadRealm() {
        recentSearchTerms = realmManager.getAllRecentSearchTerms()
        print(recentSearchTerms)
        tableView.reloadData()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width - 41
            self.cancelButtonLeadingConstraint.constant = 16
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width
            self.cancelButtonLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            self.cancelButton.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /// 아이디 검색 서버통신
    /// - Parameter searchText: 검색어
    func sendTextToServer(_ searchText: String) {
        isCurrentlyFetching = true
        SearchDataService.shared.getIdSearch(keyword: searchText) { response in
            switch response {
            case .success(let data):
                print("success!!!!")
                print(data)
                self.idSearchResponseData = data
                guard let result = self.idSearchResponseData?.result else { return }
                
                let newPosts = result.memberList
                let startIndex = self.memberList.count
                let endIndex = startIndex + newPosts.count
                let newIndexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                
                self.memberList.append(contentsOf: newPosts)
                self.isLastPage = result.pageInfo.lastPage
                
                DispatchQueue.main.async {
                    if self.currentFetchingPage == 0 {
                        self.resultVC.tableView.reloadData()
                    } else {
                        self.resultVC.tableView.insertRows(at: newIndexPaths, with: .none)
                    }
                    self.isCurrentlyFetching = false
                    self.currentFetchingPage += 1;
                }
            case .requestErr(let err):
                print(err)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
}

// MARK: - Extension: UITableView

extension RecentSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return recentSearchTerms.count
        } else if tableView == self.resultVC.tableView {
            return memberList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as! SearchResultTableViewCell
        
        if tableView == self.tableView {
            let recentSearchTerm = recentSearchTerms[indexPath.row]
            cell.userHandle.text = recentSearchTerm.term
            cell.userName.text = recentSearchTerm.name
            cell.deleteBtn.isHidden = false
            
            if let url = URL(string: recentSearchTerm.profileImg) {
                cell.profileImg.load(with: url)
            }
            
            cell.deleteButtonAction = {
                print("Delete button tapped for term: \(recentSearchTerm.term)")
                
                self.realmManager.deleteRecentSearchTerm(term: recentSearchTerm.term)
                tableView.reloadData()
            }
        } else if tableView == self.resultVC.tableView {
            let urls = self.memberList.map { $0.profileImage }
            let handles = self.memberList.map { $0.handle }
            let names = self.memberList.map { $0.name }
            
            cell.userHandle.text = handles[indexPath.item]
            cell.userName.text = names[indexPath.item]
            cell.deleteBtn.isHidden = true
            
            if let url = URL(string: urls[indexPath.item]) {
                cell.profileImg.load(with: url)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let selectedUserData = recentSearchTerms[indexPath.row]
            let handle = selectedUserData.term
            let name = selectedUserData.name
            let profileImg = selectedUserData.profileImg
            
            handleSelectedUser(handle: handle, name: name, profileImg: profileImg)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView == self.resultVC.tableView {
            let selectedUserData = memberList[indexPath.row]
            let handle = selectedUserData.handle
            let name = selectedUserData.name
            let profileImg = selectedUserData.profileImage
            
            handleSelectedUser(handle: handle, name: name, profileImg: profileImg)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func handleSelectedUser(handle: String, name: String, profileImg: String) {
        realmManager.addRecentSearch(term: handle, profileImg: profileImg, name: name)
        loadRealm()
        
        let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
        let profileTabVC = storyboard.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileViewController
        
        profileTabVC.recievedHandle = handle
        self.navigationController?.pushViewController(profileTabVC, animated: true)
    }
}

// MARK: - Extension: UIScrollView

extension RecentSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                self.sendTextToServer(currentText)
            }
        }
    }
}
