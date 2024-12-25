//
//  MemoryGalleryViewModel.swift
//  pochak
//
//  Created by Haru on 12/25/24.
//

import Foundation

class MemoryGalleryViewModel {
    let type: MemoryType
    let userID: String
    var memorySectionList: [MonthSection] = []
    var onPostListUpdated: (([MonthSection]) -> Void)?
    
    init(userID: String, type: MemoryType) {
        self.userID = userID
        self.type = type
    }
    
    func loadMemoriesData() {
        switch type {
        case .pochak:
            return getPochackMemories()
        case .bonded:
            return getBondedMemories()
        case .pochaked:
            return getPochackedMemories()
        }
        
    }
    
    private func getPochackMemories() {
        MemoriesService.getMemoriesPochak(userId: userID) {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let pochakMemoryList):
                print("💡내가 찍은 것: pochakMemoryList\n", pochakMemoryList.result)
                let sectionList = pochakMemoryList.result.createMonthSections()//MemoryList.sampleData.createMonthSections()
                self.memorySectionList = sectionList
                self.onPostListUpdated?(sectionList)
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
    }
    
    private func getBondedMemories() {
        MemoriesService.getMemoriesBonded(userId: userID) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let bondedMemoryList):
                let sectionList = MemoryList.sampleData.createMonthSections()
                self.memorySectionList = sectionList
                self.onPostListUpdated?(sectionList)
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
    }
    
    private func getPochackedMemories() {
        MemoriesService.getMemoriesPochaked(userId: userID) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let pochakedMemoryList):
                let sectionList = MemoryList.sampleData.createMonthSections()
                self.memorySectionList = sectionList
                self.onPostListUpdated?(sectionList)
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
    }
}
