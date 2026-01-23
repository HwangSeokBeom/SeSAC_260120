//
//  ShoppingSearchUseCasing.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/23/26.
//

import Foundation

protocol ShoppingSearchUseCasing {
    // 새로운 검색(또는 정렬 변경) – page1부터 다시
    func reset(
        query: String,
        sort: NaverSort,
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    )
    
    // 다음 페이지 로드 – 현재 query/sort 그대로 이어서
    func loadNext(
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    )
}
