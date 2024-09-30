////
////  MyProfileUpdateDataManager.swift
////  pochak
////
////  Created by Seo Cindy on 1/14/24.
////
//
//import Alamofire
//
//class ProfileUpdateDataManager{
//    static let shared = ProfileUpdateDataManager()
//
//    func updateDataManager(_ name : String,
//                         _ handle : String,
//                         _ message : String,
//                         _ profileImage : UIImage?,
//                         _ completion: @escaping (ProfileUpdateDataModel) -> Void) {
//        
//        let accessToken = GetToken.getAccessToken()
//
//        let header : HTTPHeaders = ["Authorization": accessToken, "Content-type": "multipart/form-data"]
//        let url = "\(APIConstants.baseURL)/api/v2/members/\(handle)"
//        let requestBody : [String : String] = [
//            "name" : name,
//            "message" : message]
//        
//        AF.upload(multipartFormData: { multipartFormData in
//            // requestBody 추가
//            for (key, value) in requestBody {
//                if let valueData = value.data(using: .utf8) {
//                    multipartFormData.append(valueData, withName: key)
//                }
//            }
//            
//            // profileImage 추가
//            if let image = profileImage?.jpegData(compressionQuality: 0.1) {
//                multipartFormData.append(image, withName: "profileImage", fileName: "profileImage.jpg", mimeType: "image/jpeg")
//            }
//        }, to: url, method: .put, headers: header).validate().responseDecodable(of: ProfileUpdateResponse.self) { response in
//                switch response.result {
//                case .success(let result):
//                    let resultData = result.result
//                    print("update 성공!!!!!!!!!!")
//                    print(resultData)
//                    completion(resultData)
//                case .failure(let error):
//                    print("updateDataManager error : \(error.localizedDescription)")
//                    if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
//                        print("Failure Data: \(errorMessage)")
//                    }
//            }
//        }
//    }
//}
