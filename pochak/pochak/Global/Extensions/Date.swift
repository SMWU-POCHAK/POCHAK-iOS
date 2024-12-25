//
//  Date.swift
//  pochak
//
//  Created by Haru on 12/2/24.
//

import Foundation

extension Date {
    static func formatDateRange(fromDateString: String) -> String {
        // Input date string을 Date 객체로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        guard let fromDate = dateFormatter.date(from: fromDateString) else {
            return ""
        }
        
        let toDate = Date() // 현재 날짜
        
        // 원하는 포맷으로 변환
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy년 MM월 dd일"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        
        let fromDateString = displayFormatter.string(from: fromDate)
        let toDateString = displayFormatter.string(from: toDate)
        
        return "\(fromDateString) ~ \(toDateString)"
    }

    static func formatTimelineDate(fromDateString: String) -> String {
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
          
          guard let fromDate = dateFormatter.date(from: fromDateString) else {
              return ""
          }
          
          let toDate = Date()
          let currentYear = Calendar.current.component(.year, from: toDate) // 현재 연도
          
          let displayFormatter = DateFormatter()
          displayFormatter.locale = Locale(identifier: "ko_KR")
          
          let fromYear = Calendar.current.component(.year, from: fromDate)
          if fromYear == currentYear {
              // 같은 연도일 경우 (년도 생략)
              displayFormatter.dateFormat = "M월 d일 (E)"
          } else {
              // 다른 연도일 경우 (년도 포함)
              displayFormatter.dateFormat = "yyyy년 M월 d일 (E)"
          }
          let fromDateString = displayFormatter.string(from: fromDate)
        
        return fromDateString
    }
    
    static func convertDate(string: String?) -> Date {
        guard let string = string else {
            return Date()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        guard let convertedDate = dateFormatter.date(from: string) else {
            return Date()
        }
        
        return convertedDate
    }
    
    static func extractDay(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        return "\(day)일"
    }
    
}
