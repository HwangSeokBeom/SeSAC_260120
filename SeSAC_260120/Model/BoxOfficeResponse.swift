//
//  BoxOfficeResponse.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

struct BoxOfficeResponse: Codable {
    let boxOfficeResult: BoxOfficeResult
}

struct BoxOfficeResult: Codable {
    let dailyBoxOfficeList: [DailyBoxOffice]
}

struct DailyBoxOffice: Codable {
    let rank: String
    let movieNm: String
    let openDt: String
}
