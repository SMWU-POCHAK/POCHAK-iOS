//
//  MyProfileUpdateDataManager.swift
//  pochak
//
//  Created by Seo Cindy on 1/14/24.
//

import Alamofire

class MyProfileUpdateDataManager{
    static let shared = MyProfileUpdateDataManager()
    
    func updateDataManager(_ name : String,
                         _ handle : String,
                         _ message : String,
                         _ profileImage : UIImage?,
                         _ completion: @escaping (MyProfileUpdateDataModel) -> Void) {
        
        let requestBody : [String : Any] = [
            "name" : name,
            "message" : message]
        
        let url = APIConstants.baseURL + "/api/v1/user/profile/" + handle
        let accessToken = GetToken().getAccessToken()
        
        /*HEADER NEEDED TO BE INCLUDED BEFORE RUNNING*/
        let header : HTTPHeaders = ["Authorization": accessToken, "Content-type": "multipart/form-data"]
        print(header[0])
        AF.upload(multipartFormData: { multipartFormData in
            //body 추가
            for (key, value) in requestBody {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            //img 추가
            if let image = profileImage?.pngData() {
                multipartFormData.append(image, withName: "profileImgUrl", fileName: "image.png", mimeType: "image/png")
            }
        }, to: url, method: .patch, headers: header).validate().responseDecodable(of: MyProfileUpdateResponse.self) { response in
                switch response.result {
                case .success(let result):
                    let resultData = result.result
                    print("update 성공!!!!!!!!!!")
                    print(resultData)
                    completion(resultData)
                case .failure(let error):
                    print("실패함!!!!")
                    print(error)
            }
        }
    }
}
