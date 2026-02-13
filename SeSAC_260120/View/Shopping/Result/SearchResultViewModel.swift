//
//  SearchResultViewModel.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/13/26.
//

import Foundation

final class SearchResultViewModel {

    private let query: String
    private let useCase: ShoppingSearchUseCasing

    private var currentSort: NaverSort = .sim
    private var isRequestingNextPage = false

    struct Output {
        let title = Observable("")
        let items = Observable<[NaverShoppingItem]>([])
        let resultCountText = Observable("0개의 검색 결과")
        let selectedSort = Observable<NaverSort>(.sim)
        let isLoading = Observable(false)
        let errorMessage = Observable<String?>(nil)
    }

    let output = Output()

    init(
        query: String,
        useCase: ShoppingSearchUseCasing = ShoppingSearchUseCase()
    ) {
        self.query = query
        self.useCase = useCase

        output.title.value = query
    }

    func viewDidLoad() {
        reset(sort: .sim)
    }

    func didTapSort(_ sort: NaverSort) {
        reset(sort: sort)
    }

    func didReachBottom() {
        loadNext()
    }

    private func reset(sort: NaverSort) {
        guard sort != currentSort || output.items.value.isEmpty else { return }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        currentSort = sort
        output.selectedSort.value = sort

        isRequestingNextPage = false
        output.isLoading.value = true
        output.errorMessage.value = nil

        useCase.reset(query: query, sort: sort) { [weak self] result in
            guard let self else { return }

            self.output.isLoading.value = false

            switch result {
            case .success(let pageItems):
                self.output.items.value = pageItems
                self.output.resultCountText.value = "\(pageItems.count)개의 검색 결과"

            case .failure(let error):
                self.output.items.value = []
                self.output.resultCountText.value = "0개의 검색 결과"
                self.output.errorMessage.value = "네이버 쇼핑 에러: \(error)"
            }
        }
    }

    private func loadNext() {
        guard !isRequestingNextPage else { return }
        isRequestingNextPage = true
        output.errorMessage.value = nil

        useCase.loadNext { [weak self] result in
            guard let self else { return }
            self.isRequestingNextPage = false

            switch result {
            case .success(let pageItems):
                guard !pageItems.isEmpty else { return }
                var current = self.output.items.value
                current.append(contentsOf: pageItems)
                self.output.items.value = current
                self.output.resultCountText.value = "\(current.count)개의 검색 결과"

            case .failure(let error):
                self.output.errorMessage.value = "네이버 쇼핑 에러: \(error)"
            }
        }
    }
}
