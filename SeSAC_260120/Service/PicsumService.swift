//
//  PicsumService.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import UIKit
import Foundation
import Kingfisher

enum PicsumService {
    
    static func fetchRandomPhoto(
        completion: @escaping (Result<PicsumPhoto, NetworkError>) -> Void
    ) {
        let randomId = Int.random(in: 0...100)
        let url = APIEndpoint.picsumInfo(id: randomId).urlString
        
        NetworkManager.shared.request(url) { (result: Result<PicsumPhoto, NetworkError>) in
            completion(result)
        }
    }
    
    static func loadImage(into imageView: UIImageView, id: String) {
        let imageURL = APIEndpoint.picsumImage(id: id, width: 600, height: 400).urlString
        
        imageView.kf.indicatorType = .activity
        
        guard let url = URL(string: imageURL) else { return }
        
        imageView.kf.setImage(
            with: url,
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }
}
