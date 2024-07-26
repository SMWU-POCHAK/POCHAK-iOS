//
//  LikedUsersDataService.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/22/23.
//

import Alamofire

struct LikedUsersDataService {
    // static을 통해 shared 프로퍼티에 싱글턴 인스턴스 저장하여 생성
    // shared를 통해 여러 VC가 같은 인스턴스에 접근 가능
    static let shared = LikedUsersDataService()
    
//    let header: HTTPHeaders = [
//        "Authorization": GetToken.getAccessToken(),
//        "Content-type": "application/json"
//    ]
    
    // 해당 포스트에 좋아요 누른 회원 조회하기
    // completion 클로저를 @escaping closure로 정의
    // -> getPersonInfo 함수가 종료되든 말든 상관없이 completion은 탈출 클로저이기 때문에, 전달된다면 이후에 외부에서도 사용가능
    // 네트워크 작업이 끝나면 completion 클로저에 네트워크의 결과를 담아서 호출하게 되고, VC에서 꺼내서 처리할 예정
    func getLikedUsers(_ postId: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        // JSONEncoding 인코딩 방식으로 헤더 정보와 함께
        // Request를 보내기 위한 정보
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/posts/\(postId)/like",
                                    method: .get,
                                    encoding: URLEncoding.default,
                                    /*headers: header*/interceptor: RequestInterceptor.getRequestInterceptor())
        
        // 통신 성공했는지에 대한 여부
        dataRequest.responseData { dataResponse in
            // dataResponse 안에는 통신에 대한 결과물
            // dataResponse.result는 통신 성공/실패 여부
            switch dataResponse.result {
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "LikedUsersDataResponse")  // 통신의 결과(성공이면 데이터, 아니면 에러내용)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    func postLikeRequest(_ postId: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/posts/\(postId)/like",
                                     method: .post,
                                     encoding: URLEncoding.default,
                                     /*headers: header*/interceptor: RequestInterceptor.getRequestInterceptor())
        
        dataRequest.responseData { dataResponse in
            switch dataResponse.result {
            case .success:
                // 성공 시 통신 자체의 상태코드와 데이터 수신
                guard let statusCode = dataResponse.response?.statusCode else { return }
                guard let value = dataResponse.value else { return }
                let networkResult = self.judgeStatus(by: statusCode, value, dataType: "LikePostDataResponse")
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
            if(dataType == "LikedUsersDataResponse") {  // 좋아요 누른 사람 조회
                let decodedData = try decoder.decode(LikedUsersDataResponse.self, from: data)  // 디코딩
                return .success(decodedData)
            }
            else {  // 좋아요 누르기 요청
                let decodedData = try decoder.decode(LikePostDataResponse.self, from: data)
                return .success(decodedData)
            }
            
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
