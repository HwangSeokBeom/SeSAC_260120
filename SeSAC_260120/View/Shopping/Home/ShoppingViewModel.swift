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

final class ShoppingViewModel: BaseViewModel {

    private let userDefaultsManager: UserDefaultsManaging

    struct Input {
        let searchText: Observable<String>
        let didTapSearch: Observable<Void>
        let didSelectRecentIndex: Observable<Int>
        let didTapDeleteRecentIndex: Observable<Int>
        let didTapClearAll: Observable<Void>
    }

    struct Output {
        let recentKeywords: Observable<[String]>
        let alertMessage: Observable<String?>
        let route: Observable<ShoppingRoute?>
        let searchText: Observable<String>
    }

    init(userDefaultsManager: UserDefaultsManaging = UserDefaultsManager()) {
        self.userDefaultsManager = userDefaultsManager
    }

    func transform(_ input: Input) -> Output {
        let recentKeywords = Observable<[String]>(
            userDefaultsManager.loadStringArray(forKey: .recentSearchKeywords)
        )
        let alertMessage = Observable<String?>(nil)
        let route = Observable<ShoppingRoute?>(nil)
        let searchText = Observable("")


        input.didTapSearch.bindWithoutInitial { [weak self] in
            guard let self else { return }

            let raw = input.searchText.value
            let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !query.isEmpty else {
                alertMessage.value = "검색어를 입력해주세요."
                return
            }

            guard query.count >= 2 else {
                alertMessage.value = "검색어를 두 글자 이상 입력해주세요."
                return
            }

            self.saveRecent(query, recentKeywords: recentKeywords)
            route.value = .showSearchResult(query: query)
        }

        input.didSelectRecentIndex.bindWithoutInitial { [weak self] idx in
            guard let self else { return }

            let list = recentKeywords.value
            guard list.indices.contains(idx) else { return }

            let keyword = list[idx]
            searchText.value = keyword

            self.saveRecent(keyword, recentKeywords: recentKeywords)
            route.value = .showSearchResult(query: keyword)
        }

        input.didTapDeleteRecentIndex.bindWithoutInitial { [weak self] idx in
            guard let self else { return }

            var list = recentKeywords.value
            guard list.indices.contains(idx) else { return }

            list.remove(at: idx)
            recentKeywords.value = list
            self.userDefaultsManager.saveStringArray(list, forKey: .recentSearchKeywords)
        }

        input.didTapClearAll.bindWithoutInitial { [weak self] in
            guard let self else { return }

            recentKeywords.value = []
            self.userDefaultsManager.remove(forKey: .recentSearchKeywords)
        }

        return Output(
            recentKeywords: recentKeywords,
            alertMessage: alertMessage,
            route: route,
            searchText: searchText
        )
    }

    private func saveRecent(_ keyword: String, recentKeywords: Observable<[String]>) {
        var list = recentKeywords.value
        if let index = list.firstIndex(of: keyword) { list.remove(at: index) }
        list.insert(keyword, at: 0)
        if list.count > 20 { list = Array(list.prefix(20)) }
        recentKeywords.value = list
        userDefaultsManager.saveStringArray(list, forKey: .recentSearchKeywords)
    }
}
