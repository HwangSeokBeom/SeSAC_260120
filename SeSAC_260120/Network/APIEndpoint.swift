//
//  APIEndpoint.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

enum APIEndpoint {
    case dailyBoxOffice(date: String)
    case picsumInfo(id: Int)
    case picsumImage(id: String, width: Int, height: Int)
    
    var urlString: String {
        switch self {
        case .dailyBoxOffice(let date):
            return "\(APIConstants.kobisBaseURL)/boxoffice/searchDailyBoxOfficeList.json?key=\(APIConstants.kobisKey)&targetDt=\(date)"
            
        case .picsumInfo(let id):
            return "\(APIConstants.picsumBaseURL)/id/\(id)/info"
            
        case .picsumImage(let id, let width, let height):
            return "\(APIConstants.picsumBaseURL)/id/\(id)/\(width)/\(height)"
        }
    }
}
