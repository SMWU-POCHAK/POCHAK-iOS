//
//  UploadDataService.swift
//  pochak
//
//  Created by 장나리 on 11/23/23.
//

import Alamofire

class UploadDataService{
    static let shared = UploadDataService()
    let accessToken = GetToken.getAccessToken()
    
    // 임시로 넣어두는 다연 토큰
    let header: HTTPHeaders = ["Authorization": APIConstants.dayeonToken,
                 "Content-type": "application/json"
                 ]

    func upload(postImage:Data?,  caption:String, taggedMemberHandleList:Array<String>, completion: @escaping(NetworkResult<Any>) -> Void){
        print("==upload==")
        
        // Create an Alamofire upload request
        AF.upload(
            multipartFormData: { multipartFormData in
                // Append image data as multipart form data
                if let imageData = postImage {
                    multipartFormData.append(imageData, withName: "postImage", fileName: "image.jpg", mimeType: "image/jpeg")
                }
                
                if let captionData = caption.data(using: .utf8) {
                    multipartFormData.append(captionData, withName: "caption")
                }
                
                // Add taggedUserHandles data
               for tag in taggedMemberHandleList {
                   if let tagData = tag.data(using: .utf8) {
                       multipartFormData.append(tagData, withName: "taggedMemberHandleList")
                   }
               }
            
            },
            to: APIConstants.baseURLv2 + "/api/v2/posts",
            method: .post,
            headers: header
        )
        .responseJSON { response in
            debugPrint(response)
            // Handle the response
            switch response.result {
            case .success(let value):
                print(value)
                if let dict = value as? [String: Any], let code = dict["code"] as? String {
                    switch code {
                    case "POST2001":
                        completion(.success(dict))
                    case "MEMBER4001":
                        print("유효하지 않은 멤버의 handle입니다.")
                        completion(.networkFail)
                    default:
                        print("Unknown code: \(code)")
                        completion(.networkFail)
                    }
                }
            case .failure(let error):
                print("Failure Error: \(error.localizedDescription)")
                if let statusCode = response.response?.statusCode {
                    print("Failure Status Code: \(statusCode)")
                }
                if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Failure Data: \(errorMessage)")
                }
                completion(.networkFail)
            }
        }
    }
}
