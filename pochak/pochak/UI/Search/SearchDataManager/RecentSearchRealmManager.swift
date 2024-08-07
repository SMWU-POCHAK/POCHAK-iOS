//
//  RecentSearchTermManager.swift
//  pochak
//
//  Created by 장나리 on 1/16/24.
//
import RealmSwift

class RecentSearchRealmManager {
    private let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    // MARK: - Create
    
    /// Realm DB에 최근 검색어 추가
    /// - Parameters:
    ///   - term: 검색 프로필 handle
    ///   - profileImg: 검색 프로필 이미지
    ///   - name: 검색 프로필 이름
    func addRecentSearch(term: String, profileImg: String, name: String) {
        if let existingSearchTerm = realm.objects(RecentSearchModel.self).filter("term == %@", term).first {
            try! realm.write {
                existingSearchTerm.date = Date()
            }
            print("Term updated")
        } else {
            let searchTerm = RecentSearchModel(term: term, profileImg: profileImg, name: name)
            try! realm.write {
                realm.add(searchTerm)
            }
            print("Term added to Realm")
        }
    }
    
    // MARK: - Read
    
    /// Realm DB에 저장된 최근검색 기록 반환
    /// - Returns: 날짜를 기준으로 내림차순
    func getAllRecentSearchTerms() -> Results<RecentSearchModel> {
        return realm.objects(RecentSearchModel.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    // MARK: - Update
    
    /// Realm DB 업데이트
    /// - Parameter term: <#term description#>
    func updateRecentSearchTerm(term: String) {
        guard let searchTerm = realm.objects(RecentSearchModel.self).filter("term == %@", term).first else {
            print("Original term not found in Realm")
            return
        }
        
        try! realm.write {
            searchTerm.date = Date()
        }
        print("Term updated in Realm")
    }
    
    // MARK: - Delete
    
    /// Realm DB에서 원하는 데이터 삭제
    /// - Parameter term: 삭제하고 싶은 handle
    func deleteRecentSearchTerm(term: String) {
        guard let searchTerm = realm.objects(RecentSearchModel.self).filter("term == %@", term).first else {
            print("Term not found in Realm")
            return
        }
        
        try! realm.write {
            realm.delete(searchTerm)
        }
        print("Term deleted from Realm")
    }
    
    /// Realm DB 데이터 전체 삭제
    /// - Returns: 성공 시 true, 실패 시 false
    func deleteAllData() -> Bool {
        do {
            try realm.write {
                realm.deleteAll()
            }
            return true
        } catch {
            print("Error deleting all data: \(error.localizedDescription)")
            return false
        }
    }
}
