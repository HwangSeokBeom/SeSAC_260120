//
//  UserDefaultsLikesStore.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/19/26.
//

import Foundation

protocol LikesStore {
    func isLiked(id: String) -> Bool
    @discardableResult func toggle(id: String) -> Bool
}

final class UserDefaultsLikesStore: LikesStore {
    private let key = "liked_item_ids"
    private let ud: UserDefaults

    init(ud: UserDefaults = .standard) {
        self.ud = ud
    }

    func isLiked(id: String) -> Bool {
        let set = Set(ud.stringArray(forKey: key) ?? [])
        return set.contains(id)
    }

    @discardableResult
    func toggle(id: String) -> Bool {
        var set = Set(ud.stringArray(forKey: key) ?? [])
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
        ud.set(Array(set), forKey: key)
        return set.contains(id)
    }
}
