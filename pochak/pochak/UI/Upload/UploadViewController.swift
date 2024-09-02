//
//  UploadViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/05.
//

import UIKit
import AVFoundation
import SwiftUI

class UploadViewController: UIViewController,UITextFieldDelegate {
    
    // MARK: - Properties
    
    var receivedImage: UIImage?
    private var searchTextField = UITextField()
    private var cancelButton = UIButton()
    
    private var currentTextCount: Int = 0
    private var currentText: String = ""
    private var shouldCallEndEditing = true

    private var memberList: [SearchMember]! = []
    
    private var isLastPage: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var currentFetchingPage: Int = 0

    private var searchTextFieldWidthConstraint: NSLayoutConstraint!
    private var cancelButtonLeadingConstraint: NSLayoutConstraint!
    
    private var tagId: [String] = []
    
    var isUploadAllowed: Bool {
        return tagId.count >= 1 && tagId.count <= 5 && currentTextCount <= 50
    }
    
    // MARK: - Views
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var captureImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var captionCountText: UILabel!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupSearchTextField()
        setupCollectionView()
        setupTableView()
    }
    
    // MARK: - Actions
    
    @objc private func backbuttonPressed(_ sender: Any) {
        print("back")
        showAlert(alertType: .confirmAndCancel,
                  titleText: "입력을 취소하고\n페이지를 나갈까요?",
                  messageText: "페이지를 벗어나면 현재 입력된 내용은\n저장되지 않으며, 모두 사라집니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
    }

    @objc private func uploadbuttonPressed(_ sender: Any) {
        guard isUploadAllowed else { return }

        let captionText = captionField.text ?? ""
        let imageData = captureImg.image?.jpegData(compressionQuality: 0.2)
        let taggedUserHandles = tagId

        print("업로드 완료")
        showProgressBar()

        UploadDataService.shared.upload(postImage: imageData, caption: captionText, taggedMemberHandleList: taggedUserHandles) { [weak self] response in
            guard let self = self else { return }
            defer { self.hideProgressBar() }

            switch response {
            case .success(let data):
                print("success", data)
                self.navigationController?.popViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            case .requestErr(let err):
                print("Request error:", err)
            case .pathErr:
                print("Path error")
            case .serverErr:
                print("Server error")
            case .networkFail:
                print("Network failure")
            }
        }
    }

    @objc private func cancelButtonClicked() {
        searchTextField.text = ""
        self.shouldCallEndEditing = true
        searchTextField.resignFirstResponder()
        self.cancelButton.isHidden = true
        self.collectionView.isHidden = false
        self.tableView.isHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width
            self.cancelButtonLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    @objc func didTextFieldChanged() {
        currentText = searchTextField.text ?? ""

        if currentText.isEmpty {
            memberList = []
            currentFetchingPage = 0
            tableView.isHidden = true
        } else {
            memberList = []
            currentFetchingPage = 0
            tableView.isHidden = false
            sendTextToServer(currentText)
        }
        tableView.reloadData()
    }
    
    // MARK: - Functions
    
    private func setupView() {
        // 이미지 설정
        if let image = receivedImage {
            captureImg.image = image
        }
        
        captionField.text = "내용 입력하기"
        captionField.textColor = UIColor(named: "gray04")
        captionField.delegate = self
        captionField.textContainerInset = UIEdgeInsets.zero
        captionField.textContainer.lineFragmentPadding = 0

        self.navigationItem.title = "누구를 포착했나요"
        self.navigationItem.leftBarButtonItem = createBackButton()
        self.navigationItem.rightBarButtonItem = createUploadButton()
    }
    
    /// 검색바 뷰 설정
    private func setupSearchTextField() {
        // 검색 textfield 설정
        searchTextField.delegate = self
        searchTextField.placeholder = "태그할 친구를 입력하세요."
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
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(
            nibName: TagCollectionViewCell.identifier,
            bundle: nil),forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
    }
    
    private func setupTableView() {
        //delegate 연결
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 8
        tableView.isHidden = true
        
        tableView.register(UINib(nibName: TagSearchTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TagSearchTableViewCell.identifier)
    }
    
    private func createBackButton() -> UIBarButtonItem {
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "ChevronLeft")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backbuttonPressed))
        backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        return backBarButtonItem
    }
    
    private func createUploadButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(title: "업로드", style: .plain, target: self, action: #selector(uploadbuttonPressed(_:)))
        button.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Pretendard-bold", size: 16)!
        ], for: .normal)
        button.tintColor = UIColor(named: "gray03")
        return button
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
        shouldCallEndEditing = true
        
        UIView.animate(withDuration: 0.3) {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width - 41
            self.cancelButtonLeadingConstraint.constant = 16
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        currentTextCount = captionField.text.count
        captionCountText.text = "\(currentTextCount)/50"
        
        // 50자 넘었을 때 글자수 빨간색으로 변경
        captionCountText.textColor = currentTextCount > 50 ? .red : .black
        
        updateUploadButton()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if shouldCallEndEditing {
            print("shouldCallEndEditing")
            self.cancelButton.isHidden = true
            self.tableView.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width
                self.cancelButtonLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.shouldCallEndEditing = false
        searchTextField.resignFirstResponder()
        self.tableView.isHidden = false
        return true
    }
    
    func sendTextToServer(_ searchText: String) {
        isCurrentlyFetching = true
        
        let request = SearchRequest(page: currentFetchingPage, keyword: searchText)
        SearchService.getSearch(request: request) { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            let newResult = data.result.memberList
            let startIndex = self?.memberList.count
            let endIndex = startIndex! + newResult.count
            let newIndexPaths = (startIndex! ..< endIndex).map { IndexPath(item: $0, section: 0) }
            
            self?.memberList.append(contentsOf: newResult)
            
            self?.isLastPage = data.result.pageInfo.lastPage
            
            let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
            
            self?.memberList = self?.memberList.filter { $0.handle != handle }
            self?.memberList = self?.memberList.filter { !self!.tagId.contains($0.handle)}
            DispatchQueue.main.async {
                if self?.currentFetchingPage == 0 {
                    self?.tableView.reloadData()
                } else {
                    self?.tableView.insertRows(at: newIndexPaths, with: .none)
                }
                self?.isCurrentlyFetching = false
                self?.currentFetchingPage += 1;
            }
        }
    }

    func updateUploadButton() {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: isUploadAllowed ? "yellow00" : "gray03")
    }
}

// MARK: - Extension: 캡션(50자 제한)

extension UploadViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "내용 입력하기" {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "내용 입력하기"
            textView.textColor = UIColor(named: "gray05")
        }
    }
}

// MARK: - Extension: 선택 태그 collectionview

extension UploadViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tagId.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError("셀 타입 캐스팅 실패2")
        }
        cell.tagIdLabel.text = self.tagId[indexPath.item]
        cell.deleteButtonAction = { [weak self] in
            guard let self = self else { return }
            
            self.tagId.remove(at: indexPath.item)
            collectionView.reloadData()
            
            updateUploadButton()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = collectionView.bounds.width - (12 * CGFloat(tagId.count - 1))
        let cellWidth = totalCellWidth / CGFloat(tagId.count)
        let inset = max((collectionView.bounds.width - CGFloat(tagId.count) * cellWidth - CGFloat(12 * (tagId.count - 1))) / 2, 0.0)
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

// MARK: - Extension: 태그 tableview

extension UploadViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagSearchTableViewCell.identifier, for: indexPath) as! TagSearchTableViewCell
        
        let handles = self.memberList.map { $0.handle }
        let names = self.memberList.map { $0.name }
        let urls = self.memberList.map { $0.profileImage }

        cell.userHandle.text = handles[indexPath.item]
        cell.userName.text = names[indexPath.item]
        if let url = URL(string: urls[indexPath.item]) {
            cell.profileImg.load(with: url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUserData = memberList[indexPath.row]
        let handles = self.memberList.map { $0.handle }
        let selectedHandle = handles[indexPath.row]
        
        // 태그는 최대 5개까지 가능함
        if tagId.count == 5 {
            showAlert(alertType: .confirmOnly,
                      titleText: "태그는 최대 5명까지 가능해요.",
                      confirmButtonText: "확인")
        }
        
        // 태그 추가가 가능한 경우, 중복을 체크하여 중복되지 않는 경우에만 추가
        else {
            if !tagId.contains(selectedHandle) {
                tagId.append(selectedHandle)
                print("Selected User Handle: \(selectedUserData.handle)")
                print(tagId)
                self.collectionView.reloadData()
            } else {
                print("이미 추가된 핸들입니다.")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateUploadButton()
        cancelButtonClicked()
    }
}

extension UploadViewController: CustomAlertDelegate {
    func confirmAction() {
        print("계속하기 선택됨")
    }
    
    func cancel() {
        print("나가기 선택됨")
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

// MARK: - Extension: UIScrollView

extension UploadViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            if (!isLastPage && !isCurrentlyFetching) {
                print("스크롤에 의해 새 데이터 가져오는 중, page: \(currentFetchingPage)")
                isCurrentlyFetching = true
                self.sendTextToServer(self.currentText)
            }
        }
    }
}
