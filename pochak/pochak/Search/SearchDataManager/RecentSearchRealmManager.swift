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
        // Get the default Realm
        self.realm = try! Realm()
        
    }

    // MARK: - Create
    func addRecentSearch(term: String, profileImg: String, name: String) {
        // Check if the term already exists in Realm
        if let existingSearchTerm = realm.objects(RecentSearchModel.self).filter("term == %@", term).first {
            // Term already exists, update the date
            try! realm.write {
                existingSearchTerm.date = Date()
            }
            print("Term updated")
        } else {
            // Term does not exist, add it to Realm
            let searchTerm = RecentSearchModel(term: term, profileImg: profileImg, name: name)
            try! realm.write {
                realm.add(searchTerm)
            }
            print("Term added to Realm")
        }
    }

    // MARK: - Read
    func getAllRecentSearchTerms() -> Results<RecentSearchModel> {
        // Retrieve all RecentSearchModel objects from Realm
        return realm.objects(RecentSearchModel.self).sorted(byKeyPath: "date", ascending: false)
    }

    // MARK: - Update
    func updateRecentSearchTerm(term: String) {
        guard let searchTerm = realm.objects(RecentSearchModel.self).filter("term == %@", term).first else {
            print("Original term not found in Realm")
            return
        }
        
        try! realm.write {
            // Update the date to reflect the modification
            searchTerm.date = Date()
        }
        print("Term updated in Realm")// After updating, refresh the list by sorting it based on the date
    }

    // MARK: - Delete
    func deleteRecentSearchTerm(term: String) {
        guard let searchTerm = realm.objects(RecentSearchModel.self).filter("term == %@", term).first else {
            print("Term not found in Realm")
            return
        }

        try! realm.write {
            // Delete the term from Realm
            realm.delete(searchTerm)
        }
        print("Term deleted from Realm")
    }
    
    // MARK: - 전체 데이터 삭제
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
