//
//  LogoutDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//
import Alamofire

class LogoutDataManager{
    
    static let shared = LogoutDataManager()
    
    
    func logoutDataManager(_ completion: @escaping (LogoutDataModel) -> Void) {
        let url = "\(APIConstants.baseURL)/api/v2/logout"
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseDecodable(of: LogoutDataModel.self) { response in
            switch response.result {
            case .success(let result):
                print("logout success!!!!!!!!!")
                let resultData = result
                completion(resultData)
            case .failure(let error):
                print("Request Fail : logoutDataManager")
                print(error)
            }
        }
    }
}
