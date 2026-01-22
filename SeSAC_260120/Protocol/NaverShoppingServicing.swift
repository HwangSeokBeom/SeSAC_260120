//
//  NaverShoppingServicing.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/22/26.
//

import Foundation

protocol NaverShoppingServicing {
    func searchShopping(
        query: String,
        start: Int,
        display: Int,
        sort: String,
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    )
}
