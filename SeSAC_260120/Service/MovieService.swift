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
        let apiKey = APIConstants.kobisKey
        let url = APIEndpoint.dailyBoxOffice(date: date).urlString
        
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

struct RealMovieService: MovieServicing {
    func fetchDailyBoxOffice(
        date: String,
        completion: @escaping (Result<[Movie], NetworkError>) -> Void
    ) {
        MovieService.fetchDailyBoxOffice(date: date, completion: completion)
    }
}

struct MockMovieService: MovieServicing {
    func fetchDailyBoxOffice(
        date: String,
        completion: @escaping (Result<[Movie], NetworkError>) -> Void
    ) {
        let mock: [Movie] = [
            .init(rank: 1, title: "도봉러의 인생영화", date: "2026-01-20"),
            .init(rank: 2, title: "고래밥의 모험", date: "2025-12-31")
        ]
        completion(.success(mock))
    }
}
