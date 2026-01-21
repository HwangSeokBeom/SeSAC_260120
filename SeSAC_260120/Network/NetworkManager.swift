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
        
        AF.request(url, headers: httpHeaders)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                    
                case .failure:
                    if let _ = response.data {
                        completion(.failure(.decodingFailed))
                    } else {
                        completion(.failure(.requestFailed))
                    }
                }
            }
    }
}
