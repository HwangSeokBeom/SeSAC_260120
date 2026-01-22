//
//  APIEndpoint.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import Foundation

enum APIEndpoint {
    case dailyBoxOffice(date: String)
    case picsumInfo(id: Int)
    case picsumImage(id: String, width: Int, height: Int)
    case naverShopping(query: String, start: Int, display: Int, sort: String)
    
    var urlString: String {
        switch self {
        case .dailyBoxOffice(let date):
            return "\(APIConstants.kobisBaseURL)/boxoffice/searchDailyBoxOfficeList.json?key=\(APIConstants.kobisKey)&targetDt=\(date)"
            
        case .picsumInfo(let id):
            return "\(APIConstants.picsumBaseURL)/id/\(id)/info"
            
        case .picsumImage(let id, let width, let height):
            return "\(APIConstants.picsumBaseURL)/id/\(id)/\(width)/\(height)"
            
        case .naverShopping(let query, let start, let display, let sort):
            var components = URLComponents(string: "\(APIConstants.naverBaseURL)/shop.json")
            components?.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "start", value: "\(start)"),
                URLQueryItem(name: "display", value: "\(display)"),
                URLQueryItem(name: "sort", value: sort)
            ]
            return components?.url?.absoluteString ?? ""
        }
    }
}
