//
//  CommentDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/26/23.
//

import Alamofire

struct CommentDataService {
    static let shared = CommentDataService()
    
    let header: HTTPHeaders = [
        "Authorization": GetToken.getAccessToken(),
        "Content-type": "application/json"
    ]
    
    /// 댓글 등록 시 서버에 전달할 Body 생성
    /// - Parameters:
    ///   - content: 댓글 내용
    ///   - parentCommentSK: 대댓글인 경우 부모댓글 아이디
    /// - Returns: 전달받은 값으로 만들어진 Parameters
    private func makeBodyParameter(content : String, parentCommentId : Int?) -> Parameters {
        if(parentCommentId != nil){
            return ["content": content, "parentCommentId": parentCommentId!]
        }
        else{
            return ["content" : content]
        }
    }
    
    /// 댓글 조회
    /// - Parameters:
    ///   - postId: 조회하고자 하는 댓글이 등록된 게시글 아이디
    ///   - page: 조회하려는 댓글 페이지 번호
    ///   - completion: 댓글 조회 후 처리할 핸들러 (뷰컨트롤러에서 정의)
    func getComments(_ postId: Int, page: Int, completion: @escaping (NetworkResult<Any>) -> Void){
        
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/posts/\(postId)/comments",
                                    method: .get,
                                    parameters: ["page": page],
                                    encoding: URLEncoding.default,
                                    headers: header)
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result{
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "CommentData")  // 통신의 결과(성공이면 데이터, 아니면 에러내용)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    /// 대댓글 조회하기
    /// - Parameters:
    ///    - postId: 대댓글을 조회하고자 하는 게시글의 아이디
    ///    - commentId:  대댓글의 부모 댓글 아이디
    ///    - page: 조회하려는 대댓글의 페이지 번호
    ///    - completion: 조회 완료 후 데이터 처리할 핸들러(뷰컨트롤러에 있음)
    ///
    func getChildComments(_ postId: Int, _ commentId: Int, page: Int, completion: @escaping (NetworkResult<Any>) -> Void){
        print("-get child comments-")
        
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/posts/\(postId)/comments/\(commentId)",
                                    method: .get,
                                    parameters: ["page": page],
                                    encoding: URLEncoding.default,
                                    headers: header)
        dataRequest.responseData { dataResponse in
            switch dataResponse.result{
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "ChildCommentData")  // 통신의 결과(성공이면 데이터, 아니면 에러내용)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }

    /// 댓글 등록하기
    /// - Parameters:
    ///   - postId: 새로 댓글을 등록하고자 하는 게시글 아이디
    ///   - content: 댓글 내용
    ///   - parentCommentSK: (대댓글인 경우에만) 부모댓글의 아이디, 댓글인 경우에는 nil 전달..?
    ///   - completion: 댓글 등록 후 데이터 처리할 핸들러(뷰컨트롤러에서 처리)
    func postComment(_ postId: Int, _ content: String, _ parentCommentId: Int?, completion: @escaping (NetworkResult<Any>) -> Void){
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/posts/\(postId)/comments",
                                    method: .post,
                                    parameters: makeBodyParameter(content: content, parentCommentId: parentCommentId),
                                    encoding: JSONEncoding.default,
                                    headers: header)
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result{
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else {return}
                print("=== dataResponse.response.statusCode: \(statusCode)")
                guard let value = dataResponse.value else {return}
                print("=== value: \(value.description)")
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "PostCommentResponse")  // 통신의 결과(성공이면 데이터, 아니면 에러내용)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    
    /// 댓글 삭제하기
    /// - Parameters:
    ///   - postId: 삭제하려는 댓글이 달린 게시글 아이디
    ///   - commentId: 삭제하려는 댓글 아이디
    ///   - completion: 댓글 삭제 후 핸들러
    func deleteComment(postId: Int, commentId: Int, completion: @escaping (NetworkResult<Any>) -> Void){
        let parameters: Parameters = ["commentId" : commentId]
        print("=== deleting comment ===")
        print("header: \(header)")
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/posts/\(postId)/comments",
                                    method: .delete,
                                    parameters: parameters,
                                    headers: header)

        dataRequest.responseData { dataResponse in
            switch dataResponse.result{
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "DeleteCommentResponse")  // 통신의 결과(성공이면 데이터, 아니면 에러내용)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    /// 요청 후 받은 statusCode를 바탕으로 결과값 처리할 방법 정의
    /// - Parameters:
    ///   - statusCode: statusCode
    ///   - data: 요청 후 받은 데이터
    ///   - dataType: 여기서는 여러 종류의 데이터를 다루고 있으므로 현재 다루고 있는 데이터 종류(모델명)
    /// - Returns: 네트워크 연결 결과 NetworkResult를 리턴
    private func judgeStatus(by statusCode: Int, _ data: Data, dataType: String) -> NetworkResult<Any> {
        print("=== judging status, code: \(statusCode)")
        
        do {
            let p = try JSONDecoder().decode(DeleteCommentResponse.self, from: data)
            print(p)
        } catch {
            print(error)
        }
        switch statusCode {
        case 200: return isValidData(data: data, dataType: dataType)  // 성공 -> 데이터 가공해서 전달해야하므로 isValidData라는 함수로 데이터 넘겨주기
        case 400: return .pathErr  // 잘못된 요청
        case 500: return .serverErr  // 서버 에러
        default: return .networkFail  // 네트워크 에러
        }
    }

    /// 통신 성공 시 데이터를 원하는대로 가공하기 위한 함수
    /// - Parameters:
    ///   - data: 받은 데이터(가공 전)
    ///   - dataType: 데이터 타입(현재 다루고 있는 데이터 모델 이름)
    /// - Returns: 네트워크 연결 결과인 NetworkResult  리턴
    private func isValidData(data: Data, dataType: String) -> NetworkResult<Any> {
        do {
            let decoder = JSONDecoder()
            if(dataType == "CommentData"){  // 댓글 조회
                let decodedData = try decoder.decode(CommentDataResponse.self, from: data)  // 디코딩
                return .success(decodedData)
            }
            else if(dataType == "ChildCommentData"){  // 대댓글 조회
                let decodedData = try decoder.decode(ChildCommentDataResponse.self, from: data)
                return .success(decodedData)
            }
            else if(dataType == "PostCommentResponse"){  // 댓글 혹은 대댓글 등록
                let decodedData = try decoder.decode(PostCommentResponse.self, from: data)
                return .success(decodedData)
            }
            else {  // 댓글 혹은 대댓글 삭제
                let decodedData = try decoder.decode(DeleteCommentResponse.self, from: data)
                return .success(decodedData)
            }
        } catch {
            print("Decoding error, comment data:", error)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            } else {
                print("Invalid JSON data received")
            }
            return .pathErr
        }
    }
}
