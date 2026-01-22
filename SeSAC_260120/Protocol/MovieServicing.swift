//
//  MovieServicing.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/22/26.
//

protocol MovieServicing {
    func fetchDailyBoxOffice(
        date: String,
        completion: @escaping (Result<[Movie], NetworkError>) -> Void
    )
}
