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
        completion: @escaping (Result<API.Response, NetworkError>) -> Void ) where API: BaseAPI {
            print("===NetworkService===")
            print(api.urlRequest)
        AF.request(api.urlRequest!, interceptor: RequestInterceptor.getRequestInterceptor())
            .validate()
            .responseData { response in
                self.handleResponse(response: response, responseType: API.Response.self, completion: completion)
            }
    }
    
    /// Alamofire을 사용해서 multipart 업로드 하는 함수
    /// - Parameters:
    ///   - api: BaseApi를 구현한 api
    ///   - completion: Handler
    func uploadMultipart<API>(
        _ api: API,
        parameters: [String: Any]? = nil,
        files: [(Data, String, String)] = [], // (파일 데이터, 이름, MIME 타입) 튜플 배열
        completion: @escaping (Result<API.Response, NetworkError>) -> Void
    ) where API: BaseAPI {
        AF.upload(multipartFormData: { multipartFormData in
            // 파일 추가
            for file in files {
                let (data, name, mimeType) = file
                multipartFormData.append(data, withName: name, fileName: "\(name).jpg", mimeType: mimeType)
            }
            
            // 파라미터 추가
            parameters?.forEach { key, value in
                if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                } else if let dataValue = value as? Data {
                    multipartFormData.append(dataValue, withName: key)
                }
            }
        }, with: api.urlRequest!, interceptor: RequestInterceptor.getRequestInterceptor())
        .validate()
        .responseData { response in
            self.handleResponse(response: response, responseType: API.Response.self, completion: completion)
        }
    }
    
    /// 공통 응답 처리하는 함수
    /// - Parameters:
    ///   - response: 서버 통신 응답
    ///   - completion: Handler
    private func handleResponse<APIResponse: Decodable>(
        response: AFDataResponse<Data>,
        responseType: APIResponse.Type,
        completion: @escaping (Result<APIResponse, NetworkError>) -> Void
    ) {
        print("handleResponse switch문 밖 = \(response)")
        switch response.result {
        case .success(let data):
            let decodeResult: Result<APIResponse, NetworkError> = self.decode(responseType, from: data)
            completion(decodeResult)
        case .failure(let error):
            if let urlError = error.underlyingError as? URLError,
               urlError.code == .notConnectedToInternet {
                completion(.failure(.disconnected))
            } else {
                let networkError = self.mapNetworkError(from: response.response)
                completion(.failure(networkError))
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
