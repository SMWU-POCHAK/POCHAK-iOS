//
//  HomeDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/27/23.
//

import Alamofire

struct HomeDataService {
    static let shared = HomeDataService()
    
    func getHomeData(page: Int, completion: @escaping (NetworkResult<HomeDataResponse>) -> Void){
        
        let dataRequest = AF.request(APIConstants.baseURLv2 + "/api/v2/posts?page=\(page)",
                                     method: .get,
                                     encoding: JSONEncoding.default,
                                     interceptor: RequestInterceptor.getRequestInterceptor())
        
        dataRequest.validate().responseDecodable(of: HomeDataResponse.self){ response in
            switch response.result {
            case .success: // 데이터 통신이 성공한 경우
                guard let statusCode = response.response?.statusCode else {return}
                guard let value = response.value else {return}
                
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
    private func judgeStatus(by statusCode: Int, _ data: HomeDataResponse) -> NetworkResult<HomeDataResponse> {
        
        switch statusCode {
        case 200: return .success(data)  // 성공 -> 데이터 가공해서 전달해야하므로 isValidData라는 함수로 데이터 넘겨주기
        case 400: return .pathErr  // 잘못된 요청
        case 500: return .serverErr  // 서버 에러
        default: return .networkFail  // 네트워크 에러
        }
    }
    
    /* !!주석처리 : 따로 파싱 과정을 거치지 않아도 dataRequest.validate().responseDecodable()에서 JSON 파싱 결과가 반환*/
    //    // 통신 성공 시 데이터를 가공하기 위한 함수
    //    private func isValidData(data: Data) -> NetworkResult<Any> {
    //        do {
    //            let decoder = JSONDecoder()
    //            let decodedData = try decoder.decode(HomeDataResponse.self, from: data)  // 디코딩
    //            return .success(decodedData)
    //        } catch {
    //            print("Decoding error, home data:", error)
    //            if let jsonString = String(data: data, encoding: .utf8) {
    //                print("Received JSON: \(jsonString)")
    //            } else {
    //                print("Invalid JSON data received")
    //            }
    //            return .pathErr
    //        }
    //    }
    //}
}
