//
//  PostDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/18/23.
//

import Alamofire

struct PostDataService {
    
    static let shared = PostDataService()
    
    /// 포스트 상세 페이지 가져오기
    /// - Parameters:
    ///   - postId: 상세 조회할 게시글 아이디
    ///   - completion: 핸들러
    func getPostDetail(_ postId: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v2/posts/\(postId)",
                                    method: .get,
                                    encoding: URLEncoding.default,
                                    interceptor: RequestInterceptor.getRequestInterceptor())
        
        // 통신 성공했는지에 대한 여부
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                // 성공 시 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "PostDetailResponse")

                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    /// 게시글 삭제하기
    /// - Parameters:
    ///   - postId: 삭제하려는 게시글 아이디
    ///   - completion: 핸들러
    func deletePost(_ postId: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v2/posts/\(postId)",
                                    method: .delete,
                                    encoding: URLEncoding.default,
                                    interceptor: RequestInterceptor.getRequestInterceptor())
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "PostDeleteResponse")
                
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    /// 게시글 신고하는 함수
    /// - Parameters:
    ///   - postId: 신고하려는 게시글 아이디
    ///   - reportType: 신고 이유 (ReportType -> ReportViewController에 선언됨)
    ///   - completion: 핸들러
    func reportPost(postId: Int, reportType: ReportType, completion: @escaping (NetworkResult<Any>) -> Void) {
        let requestBody: [String: Any] = [
            "postId": postId,
            "reportType": reportType.rawValue
        ]
        
        print("신고하기 api 실행 전, requestBody: \(requestBody)")
        
        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v1/reports",
                                     method: .post,
                                     parameters: requestBody,
                                     encoding: JSONEncoding.default,
                                     /*headers: header*/interceptor: RequestInterceptor.getRequestInterceptor())
        
        print("신고하기 request: \(dataRequest)")
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "PostReportResponse")
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    // 요청 후 받은 statusCode를 바탕으로 어떻게 결과값을 처리할 지 정의
    private func judgeStatus(by statusCode: Int, _ data: Data, dataType: String) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return isValidData(data: data, dataType: dataType)  // 성공 -> 데이터 가공해서 전달해야하므로 isValidData라는 함수로 데이터 넘겨주기
        case 400: return .pathErr  // 잘못된 요청
        case 500: return .serverErr  // 서버 에러
        default: return .networkFail  // 네트워크 에러
        }
    }
    
    // 통신 성공 시 데이터를 가공하기 위한 함수
    private func isValidData(data: Data, dataType: String) -> NetworkResult<Any> {
        do {
            let decoder = JSONDecoder()
            
            if (dataType == "PostDetailResponse") {
                let decodedData = try decoder.decode(PostDataResponse.self, from: data)
                return .success(decodedData)
            }
            else if (dataType == "PostReportResponse") {
                let decodedData = try decoder.decode(PostReportResponse.self, from: data)
                return .success(decodedData)
            }
            else {
                let decodedData = try decoder.decode(PostDeleteResponse.self, from: data)
                return .success(decodedData)
            }
            
        } catch {
            print("Decoding error:", error)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            } else {
                print("Invalid JSON data received")
            }
            return .pathErr
        }
    }
}
