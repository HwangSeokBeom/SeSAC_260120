//
//  MovieAlert.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

enum MovieAlert {
    case empty
    case failure(NetworkError)
    case invalidDate
    
    var message: String {
        switch self {
        case .empty:
            return "해당 날짜에 데이터가 없습니다.\n미래 날짜이거나 박스오피스 정보가 없는 날입니다."
        case .failure(let error):
            return "데이터 요청 실패: \(error)"
        case .invalidDate:
            return "잘못된 날짜 형식입니다.\n예: 20120101 처럼 8자리 숫자로 입력해주세요."
        }
    }
}
