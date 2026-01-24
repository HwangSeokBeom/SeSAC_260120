//
//  NetworkError.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case clientError(Int)  
    case serverError(Int)
}
