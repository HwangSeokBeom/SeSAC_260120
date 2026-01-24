//
//  PicsumServicing.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/22/26.
//

import UIKit

protocol PicsumServicing {
    func fetchRandomPhoto(
        completion: @escaping (Result<PicsumPhoto, NetworkError>) -> Void
    )
    
    func loadImage(into imageView: UIImageView, id: String)
}
