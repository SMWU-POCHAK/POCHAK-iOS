//
//  String+.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/2/24.
//

import Foundation

extension String {
    
    /// "2023-12-27T19:03:32.701"와 같은 Time형의 String이 현재 시간과 얼마 차이가 나는지 계산해서 리턴해주는 메소드.
    /// 반드시 Time과 동일한 형태의 String에서 호출해야함)
    /// - Returns: 1초, 15주와 같은 String 리턴
    func getTimeIntervalOfDateAndNow() -> String {
        let arr = self.split(separator: "T")  // T를 기준으로 자름, ["2023-12-27", "19:03:32.701"]
        let timeArr = arr[arr.endIndex - 1].split(separator: ".")  // ["19:03:32", "701"]
        
        let uploadedTime = arr[arr.startIndex] + " " + timeArr[timeArr.startIndex]  // "2023-12-27 19:03:32
        
        let currentTime = Date()
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startTime = format.date(from: String(uploadedTime))!
        let endTime = format.date(from: format.string(from: currentTime))
        
        let timePassed = Int(endTime!.timeIntervalSince(startTime))  // 초단위 리턴
        
        // 초
        if(timePassed >= 0 && timePassed < 60) {
            return String(timePassed) + "초"
        }
        // 분
        else if(timePassed >= 60 && timePassed < 3600) {
            return String(timePassed / 60) + "분"
        }
        // 시
        else if(timePassed >= 3600 && timePassed < 24 * 60 * 60) {
            return String(timePassed / 3600) + "시간"
        }
        
        // 일
        else if(timePassed >= 24 * 60 * 60 && timePassed < 7 * 24 * 60 * 60) {
            return String(timePassed/(24 * 60 * 60)) + "일"
        }
        
        // 주
        else {
            return String(timePassed / (7 * 24 * 60 * 60)) + "주"
        }
    }
    
    /// 아이디(핸들)로 허용 가능한 문자를 제한하는 메소드 (영어 대 소문자, 숫자, _(언더바), .(마침표) 만 허용함)
    /// - Returns: 아이디(핸들) 규칙 따르는지의 여부(Bool()
    func checkHandleValidity() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z_.]$", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self,
                                        options: NSRegularExpression.MatchingOptions.reportCompletion,
                                        range: NSMakeRange(0, self.count)) {
                return true
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
        return false
    }
}
