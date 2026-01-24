//
//  PicsumPhoto.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

struct PicsumPhoto: Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case downloadURL = "download_url"
    }
}
