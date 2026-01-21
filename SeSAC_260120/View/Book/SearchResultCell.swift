//
//  SearchResultCell.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import UIKit
import Kingfisher
import SnapKit

struct CampingItem {
    let imageURL: String?
    let shopName: String
    let title: String
    let priceText: String
}

final class SearchResultCell: UICollectionViewCell {
    
    static let identifier = "SearchResultCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    private let heartButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private let shopLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        return label
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        contentView.backgroundColor = .black
        
        contentView.addSubview(cardView)
        
        [thumbnailImageView, heartButton, shopLabel, titleLabel, priceLabel].forEach { cardView.addSubview($0)
        }
        
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(thumbnailImageView.snp.width).multipliedBy(0.72)
        }
        
        heartButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.trailing.bottom.equalTo(thumbnailImageView).inset(8)
        }
        
        shopLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(10)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(shopLabel.snp.bottom).offset(4)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.bottom.equalToSuperview().inset(10)
        }
    }

    func configure(with item: CampingItem) {
        shopLabel.text = item.shopName
        titleLabel.text = item.title
        priceLabel.text = item.priceText
        
        if let urlString = item.imageURL, let url = URL(string: urlString) {
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = UIImage(named: "placeholder")
        }
    }
}
