//
//  MemoriesSummaryViewController.swift
//  pochak
//
//  Created by Haru on 10/21/24.
//

import UIKit

class MemoriesSummaryViewController: UIViewController {
    private let viewModel: MemoriesSummaryViewModel
    
    init(viewModel: MemoriesSummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        viewModel.loadMemoriesData()
    }
}


class MemoriesSummaryViewModel {
    private var userID: String
    private var memorySummary: MemorySummary?
    private var bondedMemoryList: MemoryList?
    private var pochakedMemoryList: MemoryList?
    private var pochakMemoryList: MemoryList?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func loadMemoriesData() {
        getSummary()
        getMemories()
    }
    
    private func getSummary() {
        MemoriesService.getMemorySummary(userId: userID) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let memorySummary):
                self.memorySummary = memorySummary.result
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
    }
    
    private func getMemories() {
        MemoriesService.getMemoriesPochak(userId: userID) {  [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let pochakMemoryList):
                self.pochakMemoryList = pochakMemoryList.result
                print("💡", pochakMemoryList.result)
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
        
        MemoriesService.getMemoriesBonded(userId: userID) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let bondedMemoryList):
                self.bondedMemoryList = bondedMemoryList.result
                print("💡", bondedMemoryList)
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
        
        MemoriesService.getMemoriesPochaked(userId: userID) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let pochakedMemoryList):
                self.pochakedMemoryList = pochakedMemoryList.result
                print("💡", pochakedMemoryList.result.pageInfo)
            case .failure(let error):
                print("💡", error.localizedDescription)
            }
        }
    }
}
