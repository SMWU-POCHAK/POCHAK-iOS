////
////  DeleteFollowerDataManager.swift
////  pochak
////
////  Created by Seo Cindy on 1/30/24.
////
//
//import Foundation
//import Alamofire
//
//class DeleteFollowerDataManager {
//    
//    static let shared = DeleteFollowerDataManager()
//    
//    func deleteFollowerDataManager(_ handle : String, _ selectedHandle : String, _ completion: @escaping (DeleteFollowerDataResponse) -> Void) {
//        
//        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/follower?followerHandle=\(selectedHandle)"
//
//        AF.request(url,
//                   method: .delete,
//                   encoding: URLEncoding.default,
//                   interceptor: RequestInterceptor.getRequestInterceptor())
//        .validate()
//        .responseDecodable(of: DeleteFollowerDataResponse.self) { response in
//            switch response.result {
//            case .success(let result):
//                completion(result)
//            case .failure(let error):
//                print("Request Fail : deleteFollowerDataManager")
//                print(error)
//            }
//        }
//    }
//}
