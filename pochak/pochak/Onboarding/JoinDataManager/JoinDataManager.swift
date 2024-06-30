//
//  JoinDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import Alamofire

struct JoinDataManager {
    
    static let shared = JoinDataManager()
    let accessToken = GetToken.getAccessToken()
    let url = "\(APIConstants.baseURL)/api/v2/member/signup"
    
    func joinDataManager(_ name : String,
                         _ email : String,
                         _ handle : String,
                         _ message : String,
                         _ socialId : String,
                         _ socialType : String,
                         _ profileImage : UIImage?,
                         _ completion: @escaping (JoinDataModel) -> Void) {
        
        let requestBody : [String : Any] = [
            "name" : name,
            "email" : email,
            "handle" : handle,
            "message" : message,
            "socialId" : socialId,
            "socialType" : socialType
//            "socialRefreshToken" :
        ]
        
        print("join url : \(url)")
    
        let header : HTTPHeaders = ["Content-type": "multipart/form-data"]
        
        AF.upload(multipartFormData: { multipartFormData in
            //body 추가
            for (key, value) in requestBody {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            //img 추가
            if let image = profileImage?.jpegData(compressionQuality: 1) {
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
