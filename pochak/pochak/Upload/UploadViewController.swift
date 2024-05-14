//
//  UploadViewController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/05.
//

import UIKit
import AVFoundation
import SwiftUI



class UploadViewController: UIViewController,UISearchBarDelegate{
    
    let textViewPlaceHolder = "한 줄 캡션 입력하기"
    
    var receivedImage : UIImage?
    
    @IBOutlet weak var captureImg: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchResultData : [idSearchResponse] = []
    
    var tagId : [String] = []
    
    lazy var backButton: UIBarButtonItem = { // 업로드 버튼
        let backBarButtonItem = UIBarButtonItem(image:UIImage(named: "back_btn"), style: .plain, target: self, action: #selector(backbuttonPressed(_:)))
        

        backBarButtonItem.tintColor = UIColor.black
        return backBarButtonItem
        }()

    lazy var rightButton: UIBarButtonItem = { // 업로드 버튼
        let button = UIBarButtonItem(title: "업로드", style: .plain, target: self, action: #selector(uploadbuttonPressed(_:)))
        button.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Pretendard-bold", size: 14)!
        ], for: .normal)
        button.tintColor = UIColor(named: "yellow00")// 색 노란색으로 바꾸기
        return button
        }()
    
    
    @IBOutlet weak var captionField: UITextView!
    
    @IBOutlet weak var captionCountText: UILabel!
    
    @IBOutlet weak var tagSearch: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 이미지 설정
        if let image = receivedImage {
            captureImg.image = image
        }
        
        self.navigationItem.rightBarButtonItem = self.rightButton // 업로드 버튼
        self.navigationItem.leftBarButtonItem = self.backButton
        
        
        captionField.text = textViewPlaceHolder
        captionField.textColor = UIColor(named: "gray04")
        captionField.delegate = self
        
        captionCountText.font = UIFont(name: "Pretendard-medium", size: 12)
        tagSearch.searchBarStyle = .minimal
        
        //테그 검색 창 버튼 이미지 설정
        tagSearch.setImage(UIImage(named: "search"), for: UISearchBar.Icon.search, state: .normal)
        
        tagSearch.setImage(UIImage(named: "clear"), for: .clear, state: .normal)
        
        //태그검색 창 글씨 크기 설정
        let attributedString = NSMutableAttributedString(string: "친구를 태그해보세요!", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Pretendard-medium",size:12) as Any
           ])
        

        tagSearch.searchTextField.attributedPlaceholder = attributedString
        tagSearch.autocapitalizationType = .none
        
        tagSearch.searchTextField.font = UIFont(name: "Pretendard-medium",size:12)
        
        //아이디 태그 collectionview
        setupCollectionView()
        setupTableView()
    }
    
    // Button event
    @objc private func backbuttonPressed(_ sender: Any) {//업로드 버튼 클릭시 어디로 이동할지
        print("back")

        let sheet = UIAlertController(title:"입력을 취소하고 페이지를 나갈까요?",message: "페이지를 벗어나면 현재 입력된 내용은 저장되지 않으며, 모두 사라집니다.", preferredStyle: UIAlertController.Style.alert)

        sheet.addAction(UIAlertAction(title: "나가기", style: .destructive, handler: { _ in
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            
        }))
                
        sheet.addAction(UIAlertAction(title: "계속하기!", style: .cancel, handler: nil))
        
        
        self.present(sheet,animated: true,completion: nil)
        
        }
    
    @objc private func uploadbuttonPressed(_ sender: Any) {//업로드 버튼 클릭시 어디로 이동할지
        
        let captionText = captionField.text ?? ""
        
        let imageData : Data? = captureImg.image?.jpegData(compressionQuality: 0.2)
        
        
        var taggedUserHandles : [String] = []
        for taggedUserHandle in tagId {
            taggedUserHandles.append(taggedUserHandle)
        }
        
        showProgressBar()

        UploadDataService.shared.upload(postImage: imageData, caption: captionText, taggedMemberHandleList: taggedUserHandles) { [self] response in
            // 함수 호출 후 프로그래스 바 숨기기
            defer {
                hideProgressBar()
            }
            
            switch response {
            case .success(let data):
                print("success")
                print(data)
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
                self.tabBarController?.selectedIndex = 0
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
        tableView.isHidden = true

        tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색 바에 새로 입력된 텍스트 출력
        print("New Search Text: \(searchText)")
        sendTextToServer(searchText)
        // 여기에서 원하는 작업을 수행할 수 있습니다.
        // 예를 들어, 새로운 텍스트를 기반으로 서버에 검색을 요청하거나 필터링을 할 수 있습니다.
    
        if (!searchText.isEmpty) {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
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
    
    func textViewDidBeginEditing(_ textView: UITextView) { // placeholder 적용 ("한 줄 캡션 입력하기")
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
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
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("view post btn tapped")
        
        // indexPath.item에 해당하는 값 가져오기
        guard indexPath.item < tagId.count else {
            return // 유효하지 않은 인덱스이면 종료
        }
        
        let itemToRemove = tagId[indexPath.item]
        
        let sheet = UIAlertController(title:"알림",message: "태그를 삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)

        sheet.addAction(UIAlertAction(title: "네", style: .destructive, handler: { _ in
            // 해당 인덱스의 값을 제거
            self.tagId.remove(at: indexPath.item)
            
            // collectionView 다시 로드하거나 업데이트
            collectionView.reloadData()
            print(self.tagId)
        }))
                
        sheet.addAction(UIAlertAction(title: "아니요", style: .cancel, handler: nil))
        
        self.present(sheet, animated: true, completion: nil)
    }



}

        
extension UploadViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return CGFloat(4)

    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return CGFloat(12)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as! SearchResultTableViewCell

        let urls = self.searchResultData.map { $0.profileUrl }
        let handles = self.searchResultData.map { $0.userHandle }
        
        cell.userHandle.text = handles[indexPath.item]
        cell.configure(with: urls[indexPath.item])
        cell.deleteBtn.isHidden = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀을 선택했을 때 수행할 동작을 여기에 추가합니다.
        // 예를 들어, 선택한 셀의 정보를 가져와서 처리하거나 화면 전환 등을 수행할 수 있습니다.

        let selectedUserData = searchResultData[indexPath.row] // 선택한 셀의 데이터 가져오기
        let handles = self.searchResultData.map { $0.userHandle }
        
        // 선택한 핸들 가져오기
        let selectedHandle = handles[indexPath.row]

        // 중복을 체크하여 중복되지 않는 경우에만 추가
        if !tagId.contains(selectedHandle) {
            tagId.append(selectedHandle)
            print("Selected User Handle: \(selectedUserData.userHandle)")
            print(tagId)
            self.collectionView.reloadData()
        } else {
            print("이미 추가된 핸들입니다.")
        }

        // 원하는 작업을 수행한 후에 선택 해제
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.isHidden = true
        self.tagSearch.text = ""
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
