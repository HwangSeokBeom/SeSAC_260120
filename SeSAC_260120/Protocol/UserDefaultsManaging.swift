//
//  UserDefaultsManaging.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/22/26.
//

protocol UserDefaultsManaging {
    func loadStringArray(forKey key: UserDefaultsManager.Key) -> [String]
    func saveStringArray(_ array: [String], forKey key: UserDefaultsManager.Key)
    func remove(forKey key: UserDefaultsManager.Key)
}
