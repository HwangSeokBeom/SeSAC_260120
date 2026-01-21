//
//  NaverShoppingResponse.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import Foundation

struct NaverShoppingResponse: Decodable {
    let total: Int
    let start: Int
    let display: Int
    let items: [NaverShoppingItem]
}

struct NaverShoppingItem: Decodable {
    let title: String
    let link: String
    let image: String
    let lprice: String
    let hprice: String
    let mallName: String
    let productId: String
    let brand: String?
    let maker: String?
    let category1: String?
    let category2: String?
    let category3: String?
    let category4: String?
}
