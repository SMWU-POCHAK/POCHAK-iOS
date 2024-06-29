//
//  LogoutDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//
import Alamofire

class LogoutDataManager{
    
    static let shared = LogoutDataManager()
    let accessToken = GetToken().getAccessToken()
    
    func logoutDataManager(_ completion: @escaping (LogoutDataModel) -> Void) {
        let url = APIConstants.baseURL + "/api/v1/user/logout"
        
        let header : HTTPHeaders = ["Authorization": accessToken, "Content-type": "application/json"]
        print(header[0])
        
        AF.request(url,
                   method: .get,
                   encoding: URLEncoding.default,
                   headers: header)
        .validate()
        .responseDecodable(of: LogoutDataResponse.self) { response in
            switch response.result {
            case .success(let result):
                print("logout success!!!!!!!!!")
                let resultData = result.result
                completion(resultData)
            case .failure(let error):
                print(error)
            }
        }
    }
}
