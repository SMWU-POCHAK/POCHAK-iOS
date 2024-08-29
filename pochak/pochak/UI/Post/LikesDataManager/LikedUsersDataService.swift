//
//  LikedUsersDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/22/23.
//

import Alamofire

struct LikedUsersDataService {
    
    static let shared = LikedUsersDataService()
    
    /// 좋아요 누른 사람들 조회
    /// - Parameters:
    ///   - postId: 조회할 게시글
    ///   - completion: 핸들러
    func getLikedUsers(_ postId: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v2/posts/\(postId)/like",
                                    method: .get,
                                    encoding: URLEncoding.default,
                                    interceptor: RequestInterceptor.getRequestInterceptor())
        
        // 통신 성공했는지에 대한 여부
        dataRequest.responseData { dataResponse in
            // dataResponse 안에는 통신에 대한 결과물
            // dataResponse.result는 통신 성공/실패 여부
            switch dataResponse.result {
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                let networkResult = self.judgeStatus(by: statusCode, value)  // 통신의 결과(성공이면 데이터, 아니면 에러내용)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    // 요청 후 받은 statusCode를 바탕으로 어떻게 결과값을 처리할 지 정의
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode {
        case 200: return isValidData(data: data)  // 성공 -> 데이터 가공해서 전달해야하므로 isValidData라는 함수로 데이터 넘겨주기
        case 400: return .pathErr  // 잘못된 요청
        case 500: return .serverErr  // 서버 에러
        default: return .networkFail  // 네트워크 에러
        }
    }
    
    // 통신 성공 시 데이터를 가공하기 위한 함수
    private func isValidData(data: Data) -> NetworkResult<Any> {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(LikedUsersDataResponse.self, from: data)
            return .success(decodedData)
            
        } catch {
            print("Decoding error, likedusers:", error)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            else {
                print("Invalid JSON data received")
            }
            return .pathErr
        }
    }
}
