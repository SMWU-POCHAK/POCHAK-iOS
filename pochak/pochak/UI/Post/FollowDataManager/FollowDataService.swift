//
//  FollowDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/3/24.
//

import Alamofire

struct FollowDataService {
    
    static let shared = FollowDataService()
    
    /// 팔로우 혹은 팔로우 취소하는 api
    /// - Parameters:
    ///   - handle: 팔로우 혹은 팔로우 취소하고자 하는 사용자의 핸들
    ///   - completion: post 요청 완료 후 데이터 처리할 핸들러 (뷰컨트롤러에 있음)
    func postFollow(_ handle: String, completion: @escaping (NetworkResult<FollowDataResponse>) -> Void) {
        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v2/members/\(handle)/follow",
                                    method: .post,
                                    encoding: URLEncoding.default,
                                    interceptor: RequestInterceptor.getRequestInterceptor())
        
        dataRequest.validate().responseDecodable(of: FollowDataResponse.self){ response in
            switch response.result {
            case .success: // 데이터 통신이 성공한 경우
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.value else { return }
                
                let networkResult = judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure(let error): // 데이터 통신이 실패한 경우
                if let statusCode = response.response?.statusCode {
                    print("Failure Status Code: \(statusCode)")
                    completion(.networkFail)
                }
                print("Failure Error: \(error.localizedDescription)")
                
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                    completion(.networkFail)
                }
            }
        }
    }
    
    // 요청 후 받은 statusCode를 바탕으로 어떻게 결과값을 처리할 지 정의
    private func judgeStatus(by statusCode: Int, _ data: FollowDataResponse) -> NetworkResult<FollowDataResponse> {
        switch statusCode {
        case 200: return .success(data)  // 성공 -> 데이터 가공해서 전달해야하므로 isValidData라는 함수로 데이터 넘겨주기
        case 400: return .pathErr  // 잘못된 요청
        case 500: return .serverErr  // 서버 에러
        default: return .networkFail  // 네트워크 에러
        }
    }
}
