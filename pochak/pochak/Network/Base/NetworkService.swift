//
//  NetworkService.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation
import Alamofire

protocol NetworkServable {
    func request<API>(_ api: API, completion: @escaping (Result<API.Response, NetworkError>) -> Void) where API: BaseAPI
}

class NetworkService: NetworkServable {
    static let shared = NetworkService()
    
    init() {}
    
    /// Alamofire을 사용해서 실제로 통신하는 함수
    /// - Parameters:
    ///   - api: BaseApi를 구현한 api
    ///   - completion: Handler
    func request<API>(
        _ api: API,
        completion: @escaping (Result<API.Response, NetworkError>) -> Void ) where API : BaseAPI {
            print("===NetworkService===")
            print(api.urlRequest)
        AF.request(api.urlRequest!, interceptor: RequestInterceptor.getRequestInterceptor())
            .validate()
            .responseData { response in
                print("switch문 밖 = \(response)")
                switch response.result {
                case .success(let data):
                    let decodeResult = self.decode(API.Response.self, from: data)
                    completion(decodeResult)
                case .failure(let error):
                    if let urlError = error.underlyingError as? URLError,
                       urlError.code == .notConnectedToInternet {
                        completion(.failure(.disconnected))
                    } else {
                        print("response")
                        print(response)
                        let networkError = self.mapNetworkError(from: response.response)
                        completion(.failure(networkError))
                    }
                }
            }
    }
    
    private func mapNetworkError(from response: HTTPURLResponse?) -> NetworkError {
        guard let response = response else {
            return .unknownError
        }
        switch response.statusCode {
        case 400..<409: return .clientError
        case 413: return .contentTooLarge
        case 503: return .multipartError
        case 500..<600: return .serverError
        default: return .unknownError
        }
    }
    
    private func decode<T>(
        _ type: T.Type,
        from data: Data
    ) -> Result<T, NetworkError> where T: Decodable {
        do {
            let decodedData = try JSONDecoder().decode(type, from: data)
            return .success(decodedData)
        } catch {
            return .failure(.unableToDecode)
        }
    }
}
