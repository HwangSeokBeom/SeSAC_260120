//
//  BookService.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import Foundation

enum NaverShoppingService {
    
    static func searchShopping(
        query: String,
        start: Int = 1,
        display: Int = 100,
        sort: String = NaverSort.sim.rawValue,
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        let urlString = APIEndpoint.naverShopping(
            query: query,
            start: start,
            display: display,
            sort: sort
        ).urlString
        
        guard urlString.isEmpty == false else {
            completion(.failure(.invalidURL))
            return
        }
        
        let headers = [
            "X-Naver-Client-Id": APIConstants.naverClientId,
            "X-Naver-Client-Secret": APIConstants.naverClientSecret
        ]
        
        NetworkManager.shared.request(
            urlString,
            headers: headers
        ) { (result: Result<NaverShoppingResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct RealNaverShoppingService: NaverShoppingServicing {
    func searchShopping(
        query: String,
        start: Int = 1,
        display: Int = 100,
        sort: String = "sim",
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        // 기존 enum을 그대로 재사용
        NaverShoppingService.searchShopping(
            query: query,
            start: start,
            display: display,
            sort: sort,
            completion: completion
        )
    }
}

struct MockNaverShoppingService: NaverShoppingServicing {
    
    func searchShopping(
        query: String,
        start: Int,
        display: Int,
        sort: String,
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        // 딱 UI 보기 좋게 임의의 더미 데이터
        let mockItems: [NaverShoppingItem] = [
            .init(
                title: "<b>도봉러</b>의 감성 텐트",
                link: "https://example.com/tent",
                image: "https://picsum.photos/200",
                lprice: "89000",
                hprice: "",
                mallName: "도봉 캠핑샵",
                productId: "1",
                brand: "Dobong",
                maker: "Dobong",
                category1: "스포츠/레저",
                category2: "캠핑",
                category3: "텐트",
                category4: "2~3인용"
            ),
            .init(
                title: "따뜻한 <b>침낭</b>",
                link: "https://example.com/sleepingbag",
                image: "https://picsum.photos/201",
                lprice: "59000",
                hprice: "",
                mallName: "도봉 캠핑샵",
                productId: "2",
                brand: "Dobong",
                maker: "Dobong",
                category1: "스포츠/레저",
                category2: "캠핑",
                category3: "침낭",
                category4: "겨울용"
            )
        ]
        // 네트워크 없이도 바로 성공 콜백 날림
        completion(.success(mockItems))
    }
}
