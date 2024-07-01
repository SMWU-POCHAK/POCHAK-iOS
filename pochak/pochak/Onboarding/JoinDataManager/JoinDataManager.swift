//
//  JoinDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import Alamofire

struct JoinDataManager {
    
    static let shared = JoinDataManager()
    let url = "\(APIConstants.baseURL)/api/v2/members/signup"
    let header : HTTPHeaders = ["Content-type": "multipart/form-data"]
    
    func joinDataManager(_ name : String,
                         _ email : String,
                         _ handle : String,
                         _ message : String,
                         _ socialId : String,
                         _ socialType : String,
                         _ socialRefreshToken : String,
                         _ profileImage : UIImage?,
                         _ completion: @escaping (JoinDataModel) -> Void) {
        
        var requestBody : [String : String] = [
            "name" : name,
            "email" : email,
            "handle" : handle,
            "message" : message,
            "socialId" : socialId,
            "socialType" : socialType
        ]
        
        if socialRefreshToken == "NOTAPPLELOGINUSER" {
        } else {
            requestBody.updateValue(socialRefreshToken, forKey: "socialRefreshToken")
        }
        
        print("requestBody : \(requestBody)")
        print("join url : \(url)")
    
        
        AF.upload(multipartFormData: { multipartFormData in
            // requestBody 추가
            for (key, value) in requestBody {
                if let valueData = value.data(using: .utf8) {
                    multipartFormData.append(valueData, withName: key)
                }
            }
            // profileImage 추가
            if let image = profileImage?.jpegData(compressionQuality: 0.1) {
                multipartFormData.append(image, withName: "profileImage", fileName: "image.jpg", mimeType: "image/jpeg")
            }
        }, to: url, method: .post, headers: header).validate().responseDecodable(of: JoinAPIResponse.self) { response in
            print("joindataManager respose: \(response)")
            print("joindataManager respose: \(response.result)")
                switch response.result {
                case .success(let result):
                    let resultData = result.result
                    completion(resultData)
                case .failure(let error):
                    print(error)
            }
        }
    }
}
