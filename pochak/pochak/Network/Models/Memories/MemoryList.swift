//
//  MemoryList.swift
//  pochak
//
//  Created by Haru on 12/25/24.
//

import Foundation

// MARK: - MemoryList
struct MemoryList: Codable {
    let pageInfo: PageInfo
    let postList: [MemoryPost]
    
    enum CodingKeys: String, CodingKey {
        case pageInfo = "pageInfo"
        case postList = "postList"
    }
}

extension MemoryList {
    func createMonthSections() -> [MonthSection] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy년 M월"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        
        let groupedPosts = Dictionary(grouping: postList) { post in
            if let date = dateFormatter.date(from: post.date ?? "") {
                return displayFormatter.string(from: date)
            }
            return ""
        }
        
        let sections = groupedPosts.map { (yearMonth, posts) in
            MonthSection(yearMonth: yearMonth,
                        posts: posts.sorted {
                guard let date1 = dateFormatter.date(from: $0.date ?? ""),
                      let date2 = dateFormatter.date(from: $1.date ?? "") else {
                    return false
                            }
                            return date1 > date2
                        })
        }
        
        return sections.sorted { section1, section2 in
            section1.yearMonth > section2.yearMonth
        }
    }
}
