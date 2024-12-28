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
                self.timeLineEvent = self.sortTimeLineEvent(memorySummary.result)
                self.summaryGalleryItem = converGalleryPostList(memorySummary: memorySummary.result)
                self.onMemorySummaryUpdated?(memorySummary.result)
            case .failure(let error):
                print("[Error] GET SUMMARY", error.localizedDescription)
            }
        }
    }
    
    private func sortTimeLineEvent(_ memory: MemorySummary) -> [TimelineItem] {
        let follow = TimelineItem(date: memory.followDate,
                                  icon: .profile,
                                  message: "내가 \(memory.handle)님을 팔로우했어요.")
        let followed = TimelineItem(date: memory.followDate,
                                    icon: .profile,
                                    message: " \(memory.handle)님이 나를 팔로우했어요.")
        let firstPochak = TimelineItem(date: memory.firstPochak.date,
                                       icon: .camera,
                                       message: "내가 \(memory.handle)님을 처음 포착했어요.")
        let firstPochaked = TimelineItem(date: memory.firstPochaked.date,
                                         icon: .camera,
                                         message: "\(memory.handle)님이 나를 처음 포착했어요.")
        let firstBonded = TimelineItem(date: memory.firstBonded.date,
                                       icon: .camera,
                                       message: "처음 함께 포착됐어요.")
        
        var events = [follow, followed, firstPochak, firstPochaked, firstBonded]
        events = events.filter{ $0.date != nil }
        let sortedEvents = events.sorted { Date.convertDate(string: $0.date) < Date.convertDate(string: $1.date) }
        return sortedEvents
    }
    
    func converGalleryPostList(memorySummary: MemorySummary) ->  [SummaryGalleryItem]{
        let pochack = SummaryGalleryItem(type: .pochak, post: memorySummary.firstPochak)
        let bonded =  SummaryGalleryItem(type: .bonded, post: memorySummary.firstBonded)
        let pochacked =  SummaryGalleryItem(type: .pochaked, post: memorySummary.firstPochaked)
        
        return [pochack, bonded, pochacked]
    }
}
