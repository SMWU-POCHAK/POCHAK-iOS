//
//  MyProfilePostDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 12/28/23.
//

import Alamofire

struct SimpleJson: Codable {
    var isSuccess: Bool
    var code: String
    var message: String
}

class MyProfilePostDataManager {
    
    static let shared = MyProfilePostDataManager()
    
    func myProfileUserAndPochakedPostDataManager(_ handle : String, _ page : Int, _ completion: @escaping (NetworkResult400<MyProfileUserAndPochakedPostModel>) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)?page=\(page)"

        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: MyProfileUserAndPochakedPostResponse.self) { response in
            print(response)
            switch response.result {
            case .success(let result):
                let resultData = result.result
                completion(.success(resultData))
            case .failure(let error):
                print("myProfileUserAndPochakedPostDataManager error : \(error.localizedDescription)")
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
                if let statusCode = response.response?.statusCode {
                    if statusCode == 400 {
                        completion(.MEMBER4002)
                    }
                }
            }
        }
    }
    
    func myProfilePochakPostDataManager(_ handle : String, _ page : Int, _ completion: @escaping (MyProfilePochakPostModel) -> Void) {
                
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/upload?page=\(page)"
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: MyProfilePochakPostResponse.self) { response in
            print(response)
            switch response.result {
            case .success(let result):
                let resultData = result.result
                completion(resultData)
            case .failure(let error):
                print("myProfilePochakPostDataManager error : \(error.localizedDescription)")
                guard let data = response.data else { return }
                // data
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(SimpleJson.self, from: data) {
                    print(">>>>> decoder : \(json.code)") // hyeon
                }
                if let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
}
