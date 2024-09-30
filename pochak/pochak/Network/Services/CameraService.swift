//
//  CameraService.swift
//  pochak
//
//  Created by 장나리 on 9/2/24.
//

import Foundation

struct CameraService {
    /// 카메라탭 게시물 업로드 함수
    /// - Parameters:
    ///   - files: 업로드할 이미지
    ///   - request: 캡션, 태그 핸들을 담은 구조체
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
    static func postUpload(
        files: [(Data, String, String)],
        request: CameraUploadRequest,
        completion: @escaping (_ succeed: CameraUploadResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.uploadMultipart(CameraAPI.postUpload(request), files: files) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postUpload error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}

