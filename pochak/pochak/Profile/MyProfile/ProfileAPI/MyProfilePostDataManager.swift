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
    
    func myProfileUserAndPochakedPostDataManager(_ handle : String, _ completion: @escaping (MyProfileUserAndPochakedPostModel) -> Void) {
        
        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)"

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
                completion(resultData)
            case .failure(let error):
                print("myProfileUserAndPochakedPostDataManager error : \(error.localizedDescription)")
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
            }
        }
    }
    
    func myProfilePochakPostDataManager(_ handle : String, _ completion: @escaping ([PostDataModel]) -> Void) {
                
        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/upload"
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: MyProfilePochakPostResponse.self) { response in
            print(response)
            switch response.result {
            case .success(let result):
                let resultData = result.result.postList
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
