//
//  ShoppingViewModel.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/13/26.
//

import Foundation

enum ShoppingRoute {
    case showSearchResult(query: String)
}

final class ShoppingViewModel {
    
    private let userDefaultsManager: UserDefaultsManaging
    
    struct Input {
        let searchText = Observable("")
        let didTapSearch = Observable(false)
        let didSelectRecentIndex = Observable<Int?>(nil)
        let didTapDeleteRecentIndex = Observable<Int?>(nil)
        let didTapClearAll = Observable(false)
    }
    
    struct Output {
        let recentKeywords = Observable<[String]>([])
        let alertMessage = Observable<String?>(nil)
        let route = Observable<ShoppingRoute?>(nil)
        let searchText = Observable("")
    }
    
    let input = Input()
    let output = Output()
    
    init(userDefaultsManager: UserDefaultsManaging = UserDefaultsManager()) {
        self.userDefaultsManager = userDefaultsManager
        
        input.didTapSearch.bindWithoutInitial { [weak self] in
            self?.handleSearch()
        }
        
        input.didSelectRecentIndex.bindWithoutInitial { [weak self] in
            self?.handleSelectRecent()
        }
        
        input.didTapDeleteRecentIndex.bindWithoutInitial { [weak self] in
            self?.handleDeleteRecent()
        }
        
        input.didTapClearAll.bindWithoutInitial { [weak self] in
            self?.clearAll()
        }
    }
    
    func load() {
        output.recentKeywords.value =
        userDefaultsManager.loadStringArray(forKey: .recentSearchKeywords)
    }
    
    func didTapSearch(with text: String) {
        input.searchText.value = text
        input.didTapSearch.value = true
    }
    
    func didSelectRecent(at index: Int) {
        input.didSelectRecentIndex.value = index
    }
    
    func didTapDeleteRecent(at index: Int) {
        input.didTapDeleteRecentIndex.value = index
    }
    
    func didTapClearAll() {
        input.didTapClearAll.value = true
    }
    
    private func handleSearch() {
        let raw = input.searchText.value
        let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            output.alertMessage.value = "검색어를 입력해주세요."
            return
        }
        
        guard query.count >= 2 else {
            output.alertMessage.value = "검색어를 두 글자 이상 입력해주세요."
            return
        }
        
        let alphabet = CharacterSet.alphanumerics
        let hangul = CharacterSet(charactersIn: "가"..."힣")
        let allowed = alphabet.union(hangul)
        
        guard query.rangeOfCharacter(from: allowed) != nil else {
            output.alertMessage.value = "유효한 검색어를 입력해주세요."
            return
        }
        
        saveRecent(query)
        output.route.value = .showSearchResult(query: query)
    }
    
    private func handleSelectRecent() {
        guard let idx = input.didSelectRecentIndex.value else { return }
        let list = output.recentKeywords.value
        guard list.indices.contains(idx) else { return }
        
        let keyword = list[idx]
        output.searchText.value = keyword
        saveRecent(keyword)
        output.route.value = .showSearchResult(query: keyword)
    }
    
    private func handleDeleteRecent() {
        guard let idx = input.didTapDeleteRecentIndex.value else { return }
        var list = output.recentKeywords.value
        guard list.indices.contains(idx) else { return }
        
        list.remove(at: idx)
        output.recentKeywords.value = list
        userDefaultsManager.saveStringArray(list, forKey: .recentSearchKeywords)
    }
    
    private func clearAll() {
        output.recentKeywords.value = []
        userDefaultsManager.remove(forKey: .recentSearchKeywords)
    }
    
    private func saveRecent(_ keyword: String) {
        var list = output.recentKeywords.value
        
        if let index = list.firstIndex(of: keyword) {
            list.remove(at: index)
        }
        list.insert(keyword, at: 0)
        
        if list.count > 20 {
            list = Array(list.prefix(20))
        }
        
        output.recentKeywords.value = list
        userDefaultsManager.saveStringArray(list, forKey: .recentSearchKeywords)
    }
}
