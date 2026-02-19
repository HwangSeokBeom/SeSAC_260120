//
//  SearchResultViewModel.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/13/26.
//

import Foundation

final class SearchResultViewModel: BaseViewModel {

    private let query: String
    private let useCase: ShoppingSearchUseCasing
    private let likesStore: LikesStore

    private var currentSort: NaverSort = .sim
    private var isRequestingNextPage = false

    init(
        query: String,
        useCase: ShoppingSearchUseCasing = ShoppingSearchUseCase(),
        likesStore: LikesStore = UserDefaultsLikesStore()
    ) {
        self.query = query
        self.useCase = useCase
        self.likesStore = likesStore
    }

    struct Input {
        let viewDidLoad: Observable<Void>
        let didTapSort: Observable<NaverSort>
        let didReachBottom: Observable<Void>
    }

    struct Output {
        let title: Observable<String>
        let cellViewModels: Observable<[SearchResultCellViewModel]> // ✅ 셀VM 배열
        let resultCountText: Observable<String>
        let selectedSort: Observable<NaverSort>
        let isLoading: Observable<Bool>
        let errorMessage: Observable<String?>
    }

    func transform(_ input: Input) -> Output {

        let title = Observable(query)
        let cellViewModels = Observable<[SearchResultCellViewModel]>([])
        let resultCountText = Observable("0개의 검색 결과")
        let selectedSort = Observable<NaverSort>(.sim)
        let isLoading = Observable(false)
        let errorMessage = Observable<String?>(nil)

        input.viewDidLoad.bindWithoutInitial { [weak self] in
            self?.reset(
                sort: .sim,
                cellViewModels: cellViewModels,
                selectedSort: selectedSort,
                isLoading: isLoading,
                resultCountText: resultCountText,
                errorMessage: errorMessage
            )
        }

        input.didTapSort.bindWithoutInitial { [weak self] sort in
            self?.reset(
                sort: sort,
                cellViewModels: cellViewModels,
                selectedSort: selectedSort,
                isLoading: isLoading,
                resultCountText: resultCountText,
                errorMessage: errorMessage
            )
        }

        input.didReachBottom.bindWithoutInitial { [weak self] in
            self?.loadNext(
                cellViewModels: cellViewModels,
                resultCountText: resultCountText,
                errorMessage: errorMessage
            )
        }

        return Output(
            title: title,
            cellViewModels: cellViewModels,
            resultCountText: resultCountText,
            selectedSort: selectedSort,
            isLoading: isLoading,
            errorMessage: errorMessage
        )
    }

    private func reset(
        sort: NaverSort,
        cellViewModels: Observable<[SearchResultCellViewModel]>,
        selectedSort: Observable<NaverSort>,
        isLoading: Observable<Bool>,
        resultCountText: Observable<String>,
        errorMessage: Observable<String?>
    ) {
        guard sort != currentSort || cellViewModels.value.isEmpty else { return }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        currentSort = sort
        selectedSort.value = sort

        isRequestingNextPage = false
        isLoading.value = true
        errorMessage.value = nil

        useCase.reset(query: query, sort: sort) { [weak self] result in
            guard let self else { return }
            isLoading.value = false

            switch result {
            case .success(let pageItems):
                let vms = pageItems.map { SearchResultCellViewModel(item: $0, likesStore: self.likesStore) }
                cellViewModels.value = vms
                resultCountText.value = "\(pageItems.count)개의 검색 결과"

            case .failure(let error):
                cellViewModels.value = []
                resultCountText.value = "0개의 검색 결과"
                errorMessage.value = "네이버 쇼핑 에러: \(error)"
            }
        }
    }

    private func loadNext(
        cellViewModels: Observable<[SearchResultCellViewModel]>,
        resultCountText: Observable<String>,
        errorMessage: Observable<String?>
    ) {
        guard !isRequestingNextPage else { return }
        isRequestingNextPage = true
        errorMessage.value = nil

        useCase.loadNext { [weak self] result in
            guard let self else { return }
            self.isRequestingNextPage = false

            switch result {
            case .success(let pageItems):
                guard !pageItems.isEmpty else { return }
                var current = cellViewModels.value
                current.append(contentsOf: pageItems.map {
                    SearchResultCellViewModel(item: $0, likesStore: self.likesStore)
                })
                cellViewModels.value = current
                resultCountText.value = "\(current.count)개의 검색 결과"

            case .failure(let error):
                errorMessage.value = "네이버 쇼핑 에러: \(error)"
            }
        }
    }
}
