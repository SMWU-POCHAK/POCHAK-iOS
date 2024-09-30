//
//  AuthenticationService.swift
//  pochak
//
//  Created by Seo Cindy on 9/30/24.
//

import Foundation

struct AuthenticationService {
    /// - Parameters:
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func signOut(
        completion: @escaping (_ succeed: SignOutResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(SignOutAPI.signOut()) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== signOut error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    static func logOut(
        completion: @escaping (_ succeed: LogOutResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(LogOutAPI.logOut()) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== logOut error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
