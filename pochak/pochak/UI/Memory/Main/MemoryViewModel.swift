//
//  MemoryViewModel.swift
//  pochak
//
//  Created by Haru on 12/15/24.
//

import Foundation

class MemoryViewModel {
    var userID: String
    var summaryGalleryItem: [SummaryGalleryItem] = []
    var timeLineEvent: [TimelineItem] = []
    var onMemorySummaryUpdated: ((MemorySummary) -> Void)?
    
    private var memorySummary: MemorySummary?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func loadMemoriesData() {
        getSummary()
    }
    
    private func getSummary() {
        MemoriesService.getMemorySummary(userId: userID) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let memorySummary):
                self.memorySummary = memorySummary.result
//                self.timeLineEvent = self.sortTimeLineEvent(memorySummary.result)
//                self.summaryGalleryItem = converGalleryPostList(memorySummary: memorySummary.result)
                self.onMemorySummaryUpdated?(memorySummary.result)
            case .failure(let error):
                print("[Error] GET SUMMARY", error.localizedDescription)
            }
        }
    }

    func converGalleryPostList(memoryList: [String: MemoryPost]) ->  [SummaryGalleryItem] {
        var itemList: [SummaryGalleryItem] = []
        for memory in memoryList {
            guard memory.value.imageURL != nil else { continue }
            let type = MemoryType(rawValue: memory.key) ?? .pochak
            let item = SummaryGalleryItem(type: type, post: memory.value)
            itemList.append(item)
        }
        
        return itemList
    }
}
