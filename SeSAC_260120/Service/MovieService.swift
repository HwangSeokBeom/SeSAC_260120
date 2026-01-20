//
//  MovieService.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import Foundation

import Foundation

enum MovieService {
    
    static func fetchDailyBoxOffice(
        date: String,
        completion: @escaping (Result<[Movie], NetworkError>) -> Void
    ) {
        let apiKey = "dc2fd1c608fd6fd91b8e275b6501c11b"
        let url = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=\(apiKey)&targetDt=\(date)"
        
        NetworkManager.shared.request(url) { (result: Result<BoxOfficeResponse, NetworkError>) in
            switch result {
            case .success(let response):
                let list = response.boxOfficeResult.dailyBoxOfficeList
                
                let movies: [Movie] = list.compactMap { item in
                    guard let rankInt = Int(item.rank) else { return nil }
                    return Movie(
                        rank: rankInt,
                        title: item.movieNm,
                        date: item.openDt
                    )
                }
                completion(.success(movies))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
