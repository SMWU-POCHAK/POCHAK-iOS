//
//  PreviewDataService.swift
//  pochak
//
//  Created by 장나리 on 7/3/24.
//

import Alamofire

class PreviewAlarmDataService{
    static let shared = PreviewAlarmDataService()
    
    let accessToken = GetToken.getAccessToken()
    
    func getTagPreview(tagId: Int, completion: @escaping (NetworkResult<Any>) -> Void){
        // header 있는 자리!
        let header: HTTPHeaders = ["Authorization": self.accessToken,
                     "Content-type": "application/json"
                     ]
        
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/alarms/\(tagId)",
                                    method: .post,
                                    encoding: URLEncoding.default,
                                    headers: header)
        
        // 통신 성공했는지에 대한 여부
        dataRequest.responseData { dataResponse in
            // dataResponse 안에는 통신에 대한 결과물
            // dataResponse.result는 통신 성공/실패 여부
            switch dataResponse.result{
            case .success:
                print(dataResponse.response)
                // 성공 시 상태코드와 데이터(value) 수신
                guard let statusCode = dataResponse.response?.statusCode else {return}
                guard let value = dataResponse.value else {return}

                let networkResult = self.judgeStatus(by: statusCode, value)
                completion(networkResult)
            case .failure:
                completion(.networkFail)
            }
        }
    }

    func postTagAccept(tagId: Int, isAccept: Bool, completion: @escaping (NetworkResult<Any>) -> Void){
        // header 있는 자리!
        let header: HTTPHeaders = ["Authorization": self.accessToken,
                     "Content-type": "application/json"
                     ]
        
        let dataRequest = AF.request(APIConstants.baseURLv2+"/api/v2/tags/\(tagId)?isAccept=\(isAccept)",
                                    method: .post,
                                    encoding: URLEncoding.default,
                                    headers: header)
        
        // 통신 성공했는지에 대한 여부
        dataRequest.responseData { dataResponse in
            // dataResponse 안에는 통신에 대한 결과물
            // dataResponse.result는 통신 성공/실패 여부
            switch dataResponse.result{
            case .success:
                print(dataResponse.response)
                // 성공 시 상태코드와 데이터(value) 수신
                completion(.success("success"))
            case .failure:
                completion(.networkFail)
            }
        }
    }
    
    private func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<Any> {
        switch statusCode{
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
            let decodedData = try decoder.decode(AlarmResponse.self, from: data)
            return .success(decodedData)
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
