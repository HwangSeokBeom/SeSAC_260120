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
        sort: String = "sim", // sim, date, asc, dsc
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        var components = URLComponents(string: "https://openapi.naver.com/v1/search/shop.json")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "start", value: "\(start)"),
            URLQueryItem(name: "display", value: "\(display)"),
            URLQueryItem(name: "sort", value: sort)
        ]
        
        guard let urlString = components?.url?.absoluteString else {
            completion(.failure(.invalidURL))
            return
        }
        
        let headers: [String: String] = [
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
