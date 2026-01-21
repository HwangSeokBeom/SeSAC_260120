//
//  APIConstants.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import Foundation

enum APIConstants {
    
    // KOBIS 영화 박스오피스
    static let kobisBaseURL = "https://kobis.or.kr/kobisopenapi/webservice/rest"
    static var kobisKey: String {
            Bundle.main.object(forInfoDictionaryKey: "KOBIS_API_KEY") as? String ?? ""
        }

    // Picsum 이미지
    static let picsumBaseURL = "https://picsum.photos"
    
    static let naverClientId = "nE4Zsn57wa4Oh5YtFqK3"
    static let naverClientSecret = "GaVgxLVgXl"
}
