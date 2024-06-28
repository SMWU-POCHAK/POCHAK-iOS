
//
//  SearchResultViewController.swift
//  pochak
//
//  Created by 장나리 on 12/27/23.
//

import Foundation
import UIKit
import RealmSwift

class RecentSearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var deleteAllButton: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    
    var searchTextField = UITextField()
    var cancelButton = UIButton()
    var isFiltering: Bool = false
    
    var resultVC = UITableViewController()

    let realm = try! Realm()
    var realmManager = RecentSearchRealmManager()
    var recentSearchTerms: Results<RecentSearchModel>!
    var filteredSearchTerms: Results<RecentSearchModel>!
    var searchResultData : [idSearchResponse] = []

    var searchTextFieldWidthConstraint: NSLayoutConstraint!
    var cancelButtonLeadingConstraint: NSLayoutConstraint!

        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("==RecentSearchViewController==")
        self.navigationController?.isNavigationBarHidden = true
        setupTableView()
        setupSearchTextField()
        loadRealm()
        setupResultViewController()
    }
    
    private func setupSearchTextField() {
        // 검색 textfield 설정
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
        
        // 검색 아이콘 설정
        let iconView = UIImageView(frame: CGRect(x: 12, y: 12, width: 24, height: 24)) // set your Own size
        iconView.image = UIImage(named: "search")
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        iconContainerView.addSubview(iconView)
        searchTextField.leftView = iconContainerView
        
        searchTextField.leftViewMode = .always
        
        // 취소 버튼 설정
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.isHidden = true
        
        // 뷰 설정
        if let searchContainerView = searchContainerView {
            searchContainerView.addSubview(searchTextField)
            searchContainerView.addSubview(cancelButton)
            
            // searchTextField
            NSLayoutConstraint.activate([
                searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
                searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
                searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
            ])
            

            searchTextFieldWidthConstraint = searchTextField.widthAnchor.constraint(equalToConstant: self.searchContainerView.frame.width)
            searchTextFieldWidthConstraint.isActive = true
            
            // cancelButton
            NSLayoutConstraint.activate([
                cancelButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 10),
                cancelButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
                cancelButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor)
            ])
            
            cancelButtonLeadingConstraint = cancelButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor)
            cancelButtonLeadingConstraint.isActive = true
        }
    }
    
    private func setupResultViewController() {
        // 검색 결과 tableViewController 설정
        resultVC = UITableViewController()
        resultVC.tableView.delegate = self
        resultVC.tableView.dataSource = self
        resultVC.tableView.separatorStyle = .none
        resultVC.tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        
        resultVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultVC.view)
        
        NSLayoutConstraint.activate([
            resultVC.view.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            resultVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        resultVC.view.isHidden = true // 초기에는 숨겨진 상태로 설정
    }
   
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
    }

    func loadRealm(){
        recentSearchTerms = realmManager.getAllRecentSearchTerms()
        print(recentSearchTerms)
        tableView.reloadData()
    }
    
    @objc private func cancelButtonClicked() {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        isFiltering = false
        loadRealm()
    }
    
    // 검색어 입력 시작
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
        resultVC.tableView.isHidden = false

        UIView.animate(withDuration: 0.3) {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width - 41
            self.cancelButtonLeadingConstraint.constant = 16
            self.view.layoutIfNeeded()
            
            self.resultVC.tableView.frame = CGRect(x: self.searchContainerView.frame.origin.x,
                                                   y: self.searchContainerView.frame.maxY,
                                                   width: self.searchContainerView.frame.width,
                                                   height: self.view.frame.height - self.searchContainerView.frame.maxY)
            self.view.layoutIfNeeded()
        }
    }
    
    // 검색어 입력 끝
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width
            self.cancelButtonLeadingConstraint.constant = 0
            
            self.resultVC.tableView.isHidden = true
            self.resultVC.tableView.frame = CGRect(x: self.searchContainerView.frame.origin.x,
                                                   y: self.searchContainerView.frame.maxY,
                                                   width: self.searchContainerView.frame.width,
                                                   height: self.view.frame.height - self.searchContainerView.frame.maxY)
            self.view.layoutIfNeeded()
        }) { _ in
            self.cancelButton.isHidden = true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if currentText.isEmpty {
            isFiltering = false
            loadRealm()
        } else {
            isFiltering = true
            filteredSearchTerms = recentSearchTerms.filter("term CONTAINS[c] %@", currentText)
            tableView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func labelTapped() {
        print("deleteAll")
        if realmManager.deleteAllData() {
            // 데이터 삭제에 성공한 경우
            recentSearchTerms = realmManager.getAllRecentSearchTerms()
            tableView.reloadData()
        } else {
            // 데이터 삭제에 실패한 경우
            print("Failed to delete all data")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else  {
            return
        }
        print(text)
        if(text != ""){
            sendTextToServer(text)
        }
        else{
            print("===text null ===")
            print(text)
            self.searchResultData = []
            self.resultVC.tableView.reloadData()
        }
    }
    
    func sendTextToServer(_ searchText: String) {
        // searchText를 사용하여 서버에 요청을 보내는 로직을 작성
        // 서버 요청을 보내는 코드 작성
        SearchDataService.shared.getIdSearch(keyword: searchText){ response in
            switch response {
            case .success(let data):
                print("success")
                print(data)
                self.searchResultData = data as! [idSearchResponse]
                DispatchQueue.main.async {
                    print("!!!!!!SearchResultData!!!!!! \(self.searchResultData)")
                    self.resultVC.tableView.reloadData() // collectionView를 새로고침하여 이미지 업데이트
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

//MARK: - 서치바 tableView
extension RecentSearchViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return recentSearchTerms.count
        } else if tableView == self.resultVC.tableView {
            return searchResultData.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as! SearchResultTableViewCell
        if tableView == self.tableView {
            let recentSearchTerm = recentSearchTerms[indexPath.row]
            print(recentSearchTerm)
            print(recentSearchTerm.term)
            cell.userHandle.text = recentSearchTerm.term
            cell.userName.text = recentSearchTerm.name
            cell.configure(with: recentSearchTerm.profileImg)
            cell.deleteBtn.isHidden = false
            
            cell.deleteButtonAction = {
               // 버튼이 클릭되었을 때 실행할 코드
               print("Delete button tapped for term: \(recentSearchTerm.term)")
               
               // 해당 코드 실행
                self.realmManager.deleteRecentSearchTerm(term: recentSearchTerm.term)
               
               // 셀을 삭제하고 테이블뷰를 갱신할 경우
               tableView.reloadData()
           }
        } else if tableView == self.resultVC.tableView {
            let urls = self.searchResultData.map { $0.profileImage }
            let handles = self.searchResultData.map { $0.handle }
            let names = self.searchResultData.map { $0.name }
            
            cell.userHandle.text = handles[indexPath.item]
            cell.userName.text = names[indexPath.item]
            cell.configure(with: urls[indexPath.item])
            cell.deleteBtn.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let selectedUserData = recentSearchTerms[indexPath.row] // 선택한 셀의 데이터 가져오기
            let handle = selectedUserData.term
            let name = selectedUserData.name
            let profileImg = selectedUserData.profileImg
            
            realmManager.addRecentSearch(term: handle, profileImg: profileImg, name: name)
            self.tableView.reloadData()
            // 화면전환
            // TODO: handle 전달
            let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
            let profileTabVC = storyboard.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileViewController
            
            profileTabVC.recievedHandle = handle
            self.navigationController?.pushViewController(profileTabVC, animated: true)
            
        } else if tableView == self.resultVC.tableView {
            let selectedUserData = searchResultData[indexPath.row] // 선택한 셀의 데이터 가져오기
            let handle = selectedUserData.handle
            let name = selectedUserData.name
            let profileImg = selectedUserData.profileImage

            realmManager.addRecentSearch(term: handle, profileImg: profileImg, name: name)
            self.tableView.reloadData()

            // 화면전환 -> handle 전달
            // TODO: handle 전달
            let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
            let profileTabVC = storyboard.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileViewController
            
            profileTabVC.recievedHandle = handle
            self.navigationController?.pushViewController(profileTabVC, animated: true)
            
        }
    }
}
