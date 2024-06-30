//
//  UploadViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/05.
//

import UIKit
import AVFoundation
import SwiftUI



class UploadViewController: UIViewController,UITextFieldDelegate{
         
    // MARK: - Views

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var captureImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var captionCountText: UILabel!
    
    // MARK: - Properties

    var receivedImage : UIImage?
    var searchResultData : [idSearchResponse] = []
    
    var searchTextField = UITextField()
    var cancelButton = UIButton()
    
    lazy var backButton: UIBarButtonItem = { // 업로드 버튼
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "ChevronLeft")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backbuttonPressed))
        backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        return backBarButtonItem
        }()

    lazy var uploadButton: UIBarButtonItem = { // 업로드 버튼
        let button = UIBarButtonItem(title: "업로드", style: .plain, target: self, action: #selector(uploadbuttonPressed(_:)))
        button.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Pretendard-bold", size: 16)!
        ], for: .normal)
        button.tintColor = UIColor(named: "gray03")
        
        return button
        }()
    
    var searchTextFieldWidthConstraint: NSLayoutConstraint!
    var cancelButtonLeadingConstraint: NSLayoutConstraint!
    
    var tagId: [String] = [] {
        didSet {
            tagIdDidChange()
        }
    }
    
    var shouldCallEndEditing = true
    
    var isUploadAllowed = false
        
    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInit()
        setupSearchTextField()
        
        //아이디 태그 collectionview, tableview
        setupCollectionView()
        setupTableView()
    }
    
    // MARK: - Functions

    private func setupInit(){
        // 이미지 설정
        if let image = receivedImage {
            captureImg.image = image
        }

        captionField.text = "내용 입력하기"
        captionField.textColor = UIColor(named: "gray04")
        captionField.delegate = self
        captionField.textContainerInset = UIEdgeInsets.zero
        captionField.textContainer.lineFragmentPadding = 0
        
        if let navigationBar = self.navigationController?.navigationBar {
                let textAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.black,
                    NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
                ]
                navigationBar.titleTextAttributes = textAttributes
            }

        
        self.navigationItem.title = "누구를 포착했나요"
        
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = uploadButton

    }
    
    private func tagIdDidChange(){
        if(!tagId.isEmpty){
            uploadButton.tintColor = UIColor(named: "yellow00")
            isUploadAllowed = true
        }
        else{
            uploadButton.tintColor = UIColor(named: "gray03")
            isUploadAllowed = false
        }
    }
    // Button event
    @objc private func backbuttonPressed(_ sender: Any) {// 뒤로가기 버튼 클릭시 어디로 이동할지
        print("back")
        
        showAlert(alertType: .confirmAndCancel,
                  titleText: "입력을 취소하고\n페이지를 나갈까요?",
                  messageText: "페이지를 벗어나면 현재 입력된 내용은\n저장되지 않으며, 모두 사라집니다.",
                  cancelButtonText: "나가기",
                  confirmButtonText: "계속하기"
        )
    }
    
    @objc private func uploadbuttonPressed(_ sender: Any) {//업로드 버튼 클릭시 어디로 이동할지
        if(isUploadAllowed){
            let captionText = captionField.text ?? ""
            
            let imageData : Data? = captureImg.image?.jpegData(compressionQuality: 0.2)
            
            var taggedUserHandles : [String] = []
            for taggedUserHandle in tagId {
                taggedUserHandles.append(taggedUserHandle)
            }
            print("업로드 완료")
            
    //        showProgressBar()
    //
    //        UploadDataService.shared.upload(postImage: imageData, caption: captionText, taggedMemberHandleList: taggedUserHandles) { [self] response in
    //            // 함수 호출 후 프로그래스 바 숨기기
    //            defer {
    //                hideProgressBar()
    //            }
    //
    //            switch response {
    //            case .success(let data):
    //                print("success")
    //                print(data)
    //                if let navController = self.navigationController {
    //                    navController.popViewController(animated: true)
    //                }
    //                self.tabBarController?.selectedIndex = 0
    //            case .requestErr(let err):
    //                print(err)
    //            case .pathErr:
    //                print("pathErr")
    //            case .serverErr:
    //                print("serverErr")
    //            case .networkFail:
    //                print("networkFail")
    //            }
    //        }
        }
    }
    
    // 검색바 설정
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
    
    // 검색바 입력 시작
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
        shouldCallEndEditing = true
        self.collectionView.isHidden = true

        UIView.animate(withDuration: 0.3) {
            self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width - 41
            self.cancelButtonLeadingConstraint.constant = 16
            self.view.layoutIfNeeded()
        }
    }
    
    // 검색바 입력 끝
    func textFieldDidEndEditing(_ textField: UITextField) {
        if shouldCallEndEditing {
            print("shouldCallEndEditing")
            self.cancelButton.isHidden = true
            self.collectionView.isHidden = false
            self.tableView.isHidden = true
        
            UIView.animate(withDuration: 0.3, animations: {
                self.searchTextFieldWidthConstraint.constant = self.searchContainerView.frame.width
                self.cancelButtonLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }

    // 검색바 텍스트
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string

        if currentText.isEmpty {
            self.tableView.isHidden = true
            self.searchResultData = []
            self.tableView.reloadData()
        } else {
            self.tableView.isHidden = false
            sendTextToServer(currentText)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.shouldCallEndEditing = false
        searchTextField.resignFirstResponder()
        self.tableView.isHidden = false
        return true
    }
    
    // 취소 버튼 클릭
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
    
    
    private func setupCollectionView(){
        //delegate 연결
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //cell 등록
        collectionView.register(UINib(
            nibName: "TagCollectionViewCell",
            bundle: nil),forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
        
    }
    
    private func setupTableView(){
        print(tableView)
        //delegate 연결
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 8
        tableView.isHidden = true
        
        tableView.backgroundColor = UIColor(named: "gray02")

        tableView.register(UINib(nibName: "TagSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "TagSearchTableViewCell")

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
                    self.tableView.reloadData() // tableView를 새로고침하여 이미지 업데이트
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

// MARK: - 캡션(50자 제한)
extension UploadViewController : UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {return false}
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        captionCountText.text = "\(currentText.count)/50" // 글자수 보여주는 label 변경
        
        if(currentText.count > 50){
            textView.textColor = .red
        }
        else{
            textView.textColor = .black
        }
        
        //최대 글자수(50자) 이상 입력 불가
        return changedText.count <= 50
    }
    
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

// MARK: - 선택 태그 collectionview

extension UploadViewController: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tagId.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else{
            fatalError("셀 타입 캐스팅 실패2")
        }
        cell.tagIdLabel.text = self.tagId[indexPath.item]
        
        
        cell.deleteButtonAction = { [weak self] in
            guard let self = self else { return }
            
            let itemToRemove = self.tagId[indexPath.item]
            
            self.tagId.remove(at: indexPath.item)
            
            collectionView.reloadData()
        }
        return cell
        
    }
}

        
extension UploadViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return CGFloat(4)

    }

    // 옆 간격
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

// MARK: - 태그 tableview
extension UploadViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagSearchTableViewCell", for: indexPath) as! TagSearchTableViewCell

        let urls = self.searchResultData.map { $0.profileImage }
        let names = self.searchResultData.map { $0.name }
        let handles = self.searchResultData.map { $0.handle }
        
        cell.userHandle.text = handles[indexPath.item]
        cell.userName.text = names[indexPath.item]
        cell.configure(with: urls[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀을 선택했을 때 수행할 동작을 여기에 추가합니다.
        // 예를 들어, 선택한 셀의 정보를 가져와서 처리하거나 화면 전환 등을 수행할 수 있습니다.

        let selectedUserData = searchResultData[indexPath.row] // 선택한 셀의 데이터 가져오기
        let handles = self.searchResultData.map { $0.handle }
        
        // 선택한 핸들 가져오기
        let selectedHandle = handles[indexPath.row]

        // 중복을 체크하여 중복되지 않는 경우에만 추가
        if !tagId.contains(selectedHandle) {
            tagId.append(selectedHandle)
            print("Selected User Handle: \(selectedUserData.handle)")
            print(tagId)
            self.collectionView.reloadData()
        } else {
            print("이미 추가된 핸들입니다.")
        }

        // 원하는 작업을 수행한 후에 선택 해제
        tableView.deselectRow(at: indexPath, animated: true)
        cancelButtonClicked()
    }
    
    

}

extension UploadViewController {
    func showProgressBar() {
        // 프로그래스 바를 추가할 부분
        let progressBar = UIActivityIndicatorView(style: .large)
        progressBar.center = view.center
        progressBar.startAnimating()
        view.addSubview(progressBar)
    }
    
    func hideProgressBar() {
        // 프로그래스 바를 제거할 부분
        if let progressBar = view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            progressBar.stopAnimating()
            progressBar.removeFromSuperview()
        }
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
