//
//  NetworkManager.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let _ = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let httpHeaders: HTTPHeaders? = {
            if let headers = headers {
                return HTTPHeaders(headers)
            } else {
                return nil
            }
        }()
        
        AF.request(url, method: method, parameters: parameters, headers: httpHeaders)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                    
                case .failure:
                    if let statusCode = response.response?.statusCode {
                        if (400..<500).contains(statusCode) {
                            completion(.failure(.clientError(statusCode)))
                        } else if (500..<600).contains(statusCode) {
                            completion(.failure(.serverError(statusCode)))
                        } else {
                            completion(.failure(.requestFailed))
                        }
                    } else if response.data != nil {
                        completion(.failure(.decodingFailed))
                    } else {
                        completion(.failure(.requestFailed))
                    }
                }
            }
    }
}
