//
//  BaseAPI.swift
//  pochak
//
//  Created by 장나리 on 8/4/24.
//

import Foundation
import Alamofire

protocol BaseAPI: URLRequestConvertible {
    associatedtype Response: Decodable
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: RequestParams? { get }
}

extension BaseAPI {
    var baseURL: String { "http://34.47.86.230/api" }
    var method: HTTPMethod { .get }
    var path: String { "" }
    var parameters: RequestParams? { nil }
    
    // URLRequestConvertible 구현
    func asURLRequest() throws -> URLRequest {
        print("baseURL = \(baseURL)")
        print("path = \(path)")
        print("param = \(parameters)")
        
        let url = try baseURL.asURL()
        var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderType.contentType.rawValue)
        
        if let parameters = parameters {
            switch parameters {
            case .query(let request):
                var params = request?.toDictionary() ?? [:]
                // 배열 타입인 파라미터를 쉼표로 구분된 문자열로 변환
                for (key, value) in params {
                    if let arrayValue = value as? [String] {
                        let joinedValue = arrayValue.joined(separator: ",")
                        params[key] = joinedValue
                    }
                }

                let queryParams = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                var components = URLComponents(string: url.appendingPathComponent(path).absoluteString)
                components?.queryItems = queryParams
                urlRequest.url = components?.url
            case .body(let request):
                let params = request?.toDictionary() ?? [:]
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        }
            
        print("==urlRequest = \(urlRequest.description)==")
        return urlRequest
    }
}

enum RequestParams {
    case query(_ parameter: Encodable?)
    case body(_ parameter: Encodable?)
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any] else { return [:] }
        return dictionaryData
    }
}
