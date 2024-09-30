////
////  FollowDataManager.swift
////  pochak
////
////  Created by Seo Cindy on 1/30/24.
////
//
//import Foundation
//import Alamofire
//
//class FollowListDataManager {
//    
//    static let shared = FollowListDataManager()
//    
//    func followerDataManager(_ handle : String, _ page : Int, _ completion: @escaping (FollowListDataModel) -> Void) {
//        
//        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)/follower?page=\(page)"
//        
//        AF.request(url,
//                   method: .get,
//                   encoding: URLEncoding.default,
//                   interceptor: RequestInterceptor.getRequestInterceptor())
//        .validate()
//        .responseDecodable(of: FollowListDataResponse.self) { response in
//            switch response.result {
//            case .success(let result):
//                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//                    print("Success Data for followerDataManager: \(errorMessage)")
//                }
//                let resultData = result.result
//                print(resultData)
//                completion(resultData)
//            case .failure(let error):
//                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//                    print("Failure Data for followerDataManager: \(errorMessage)")
//                }
//                print("Request Fail : followerDataManager")
//                print(error)
//            }
//        }
//    }
//    
//    func followingDataManager(_ handle : String, _ page : Int, _ completion: @escaping (FollowListDataModel) -> Void) {
//        
//        let url = "\(APIConstants.baseURLv2)/api/v2/members/\(handle)/following?page=\(page)"
//        
//        AF.request(url,
//                   method: .get,
//                   encoding: URLEncoding.default,
//                   interceptor: RequestInterceptor.getRequestInterceptor())
//        .validate()
//        .responseDecodable(of: FollowListDataResponse.self) { response in
//            print(response)
//            switch response.result {
//            case .success(let result):
//                let resultData = result.result
//                completion(resultData)
//            case .failure(let error):
//                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//                    print("Failure Data for followingDataManager: \(errorMessage)")
//                }
//                print("Request Fail : followingDataManager")
//                print(error)
//            }
//        }
//    }
//}
