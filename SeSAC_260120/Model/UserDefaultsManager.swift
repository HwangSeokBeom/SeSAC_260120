//
//  Untitled.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/22/26.
//

import Foundation

final class UserDefaultsManager: UserDefaultsManaging {
    
    enum Key: String {
        case recentSearchKeywords
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func loadStringArray(forKey key: Key) -> [String] {
        return defaults.stringArray(forKey: key.rawValue) ?? []
    }
    
    func saveStringArray(_ array: [String], forKey key: Key) {
        defaults.set(array, forKey: key.rawValue)
    }
    
    func remove(forKey key: Key) {
        defaults.removeObject(forKey: key.rawValue)
    }
}

/*
let testDefaults = UserDefaults(suiteName: "TestDefaults")!
let manager = UserDefaultsManager(defaults: testDefaults)

// 테스트용 저장
manager.save(["맥북"], forKey: .recentSearchKeywords)

// 집 서랍장 출력
print(UserDefaults.standard.stringArray(forKey: "recentSearchKeywords")) // nil   ---> ????

// 테스트 서랍장 출력
print(testDefaults.stringArray(forKey: "recentSearchKeywords")) // ["맥북"]

*/
