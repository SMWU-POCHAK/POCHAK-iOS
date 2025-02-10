//
//  Date+.swift
//  pochak
//
//  Created by Haru on 12/2/24.
//

import Foundation

extension Date {
    static func formatDateRange(fromDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        guard let fromDate = dateFormatter.date(from: fromDateString) else {
            return ""
        }
        
        let toDate = Date()
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
            displayFormatter.dateFormat = "M월 d일 (E)"
        } else {
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
