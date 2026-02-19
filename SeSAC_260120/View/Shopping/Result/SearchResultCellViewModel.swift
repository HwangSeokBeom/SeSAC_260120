//
//  SearchResultCellViewModel.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/19/26.
//

import Foundation

final class SearchResultCellViewModel {

    struct Output {
        let shopName: Observable<String>
        let title: Observable<String>
        let priceText: Observable<String>
        let imageURL: Observable<URL?>
        let isLiked: Observable<Bool>
    }

    let output: Output

    private let id: String
    private let likesStore: LikesStore

    init(item: NaverShoppingItem, likesStore: LikesStore) {
        self.likesStore = likesStore

        self.id = item.link

        let cleanTitle = item.title
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")

        output = Output(
            shopName: Observable(item.mallName),
            title: Observable(cleanTitle),
            priceText: Observable("\(item.lprice)원"),
            imageURL: Observable(URL(string: item.image)),
            isLiked: Observable(likesStore.isLiked(id: self.id))
        )
    }

    func didTapHeart() {
        let newState = likesStore.toggle(id: id)
        output.isLiked.value = newState
    }
}
