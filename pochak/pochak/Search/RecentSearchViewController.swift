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
    
    // MARK: - Views
    
    @IBOutlet weak var deleteAllButton: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    
    // MARK: - Properties
    
    var searchTextField = UITextField()
    var cancelButton = UIButton()
    
    var resultVC = UITableViewController()

    let realm = try! Realm()
    var realmManager = RecentSearchRealmManager()
    var recentSearchTerms: Results<RecentSearchModel>!
    
    var idSearchResponseData : IdSearchResponse!
    var memberList : [IdSearchMember]! = []
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0

    var currentText : String = ""

    var searchTextFieldWidthConstraint: NSLayoutConstraint!
    var cancelButtonLeadingConstraint: NSLayoutConstraint!

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("==RecentSearchViewController==")
        
        // back 버튼 커스텀
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        
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
        setupResultViewLayout()
    }
    // MARK: - Functions
    
    // 전체 삭제 액션
    private func deleteAllBtnAction(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        deleteAllButton.isUserInteractionEnabled = true
        deleteAllButton.addGestureRecognizer(tapGesture)
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
    
    // 검색바 설정
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
        searchTextField.addTarget(self, action: #selector(didTextFieldChanged), for: .editingChanged)
        
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
            
            let textFieldHeightConstraint = searchTextField.heightAnchor.constraint(equalToConstant: searchContainerView.frame.height)
            textFieldHeightConstraint.isActive = true

            searchTextFieldWidthConstraint = searchTextField.widthAnchor.constraint(equalToConstant: self.searchContainerView.frame.width)
            searchTextFieldWidthConstraint.isActive = true
            
            // cancelButton
            NSLayoutConstraint.activate([
                cancelButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 10),
                cancelButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
                cancelButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor)
            ])
            
            let cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalTo: searchContainerView.heightAnchor)
            cancelButtonHeightConstraint.isActive = true
            
            
            cancelButtonLeadingConstraint = cancelButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor)
            cancelButtonLeadingConstraint.isActive = true
        }
    }
    
    // 검색바 입력 시작
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false

        UIView.animate(withDuration: 0.3) {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width - 41
            self.cancelButtonLeadingConstraint.constant = 16
            
            self.view.layoutIfNeeded()
        }
    }
    
    // 검색바 입력 끝
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width
            self.cancelButtonLeadingConstraint.constant = 0
            
            self.view.layoutIfNeeded()
        }) { _ in
            self.cancelButton.isHidden = true
        }
    }

    // 검색바 텍스트
    @objc func didTextFieldChanged() {
        currentText = self.searchTextField.text ?? ""
        if currentText.isEmpty {
            self.currentFetchingPage = 0
            self.resultVC.tableView.isHidden = true
            self.memberList = []
            self.resultVC.tableView.reloadData()
        } else {
            self.currentFetchingPage = 0
            self.resultVC.tableView.isHidden = false
            print(currentText)
            sendTextToServer(currentText)
            tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 취소 버튼 클릭
    @objc private func cancelButtonClicked() {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        resultVC.view.isHidden = true
        loadRealm()
    }
    
    // 검색 결과
    private func setupResultViewController() {
        // 검색 결과 tableViewController 설정
        resultVC = UITableViewController()
        resultVC.tableView.delegate = self
        resultVC.tableView.dataSource = self
        resultVC.tableView.separatorStyle = .none
        resultVC.tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        
        resultVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultVC.view)
        
        resultVC.view.isHidden = true // 초기에는 숨겨진 상태로 설정
    }
   
    // 검색 결과 테이블 뷰 레이아웃 설정
    private func setupResultViewLayout(){
        NSLayoutConstraint.activate([
            resultVC.view.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 16),
            resultVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            resultVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            resultVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
    
    func sendTextToServer(_ searchText: String) {
        isCurrentlyFetching = true
        SearchDataService.shared.getIdSearch(keyword: searchText){ response in
            switch response {
            case .success(let data):
                print("success!!!!")
                print(data)
                self.idSearchResponseData = data as? IdSearchResponse
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

//MARK: - 서치바 tableView
extension RecentSearchViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return recentSearchTerms.count
        } else if tableView == self.resultVC.tableView {
            return memberList.count
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
            let urls = self.memberList.map { $0.profileImage }
            let handles = self.memberList.map { $0.handle }
            let names = self.memberList.map { $0.name }
            
            cell.userHandle.text = handles[indexPath.item]
            cell.userName.text = names[indexPath.item]
            cell.configure(with: urls[indexPath.item])
            cell.deleteBtn.isHidden = true
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
        // 최근 검색어 추가
        realmManager.addRecentSearch(term: handle, profileImg: profileImg, name: name)
        loadRealm()
        // 화면 전환
        let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
        let profileTabVC = storyboard.instantiateViewController(withIdentifier: "OtherUserProfileVC") as! OtherUserProfileViewController
        
        profileTabVC.recievedHandle = handle
        self.navigationController?.pushViewController(profileTabVC, animated: true)
    }

}

// MARK: - Extension; UIScrollView

extension RecentSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.bounds.size.height)){
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                self.sendTextToServer(currentText)
            }
        }
    }
}
