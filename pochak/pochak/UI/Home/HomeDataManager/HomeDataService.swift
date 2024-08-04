//
//  HomeDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/27/23.
//

import Alamofire

struct HomeDataService {
    static let shared = HomeDataService()
    
//    func getHomeData(page: Int, completion: @escaping (NetworkResult<HomeDataResponse>) -> Void) {
//        
//        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v2/posts?page=\(page)",
//                                     method: .get,
//                                     encoding: JSONEncoding.default,
//                                     interceptor: RequestInterceptor.getRequestInterceptor())
//        
//        dataRequest.validate().responseDecodable(of: HomeDataResponse.self) { response in
//            switch response.result {
//            case .success:
//                guard let statusCode = response.response?.statusCode else { return }
//                guard let value = response.value else { return }
//                
//                let networkResult = judgeStatus(by: statusCode, value)
//                completion(networkResult)
//            case .failure(let error):
//                if let statusCode = response.response?.statusCode {
//                    print("Failure Status Code: \(statusCode)")
//                    completion(.networkFail)
//                }
//                print("Failure Error: \(error.localizedDescription)")
//                
//                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//                    print("Failure Data: \(errorMessage)")
//                    completion(.networkFail)
//                }
//            }
//        }
//    }
//    
//    // 요청 후 받은 statusCode를 바탕으로 어떻게 결과값을 처리할 지 정의
//    private func judgeStatus(by statusCode: Int, _ data: HomeDataResponse) -> NetworkResult<HomeDataResponse> {
//        switch statusCode {
//        case 200: return .success(data)
//        case 400: return .pathErr
//        case 500: return .serverErr
//        default: return .networkFail
//        }
//    }
}
