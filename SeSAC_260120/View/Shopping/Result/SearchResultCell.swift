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

    private var viewModel: SearchResultCellViewModel?
    private var bindToken = UUID()

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
        heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bindToken = UUID()
        viewModel = nil
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        shopLabel.text = nil
        titleLabel.text = nil
        priceLabel.text = nil
        setHeart(isLiked: false)
    }

    @objc private func didTapHeart() {
        viewModel?.didTapHeart()
    }

    func configure(with viewModel: SearchResultCellViewModel) {
        self.viewModel = viewModel

        let token = UUID()
        bindToken = token

        viewModel.output.shopName.bind { [weak self] text in
            guard let self, self.bindToken == token else { return }
            self.shopLabel.text = text
        }

        viewModel.output.title.bind { [weak self] text in
            guard let self, self.bindToken == token else { return }
            self.titleLabel.text = text
        }

        viewModel.output.priceText.bind { [weak self] text in
            guard let self, self.bindToken == token else { return }
            self.priceLabel.text = text
        }

        viewModel.output.imageURL.bind { [weak self] url in
            guard let self, self.bindToken == token else { return }
            if let url {
                self.thumbnailImageView.kf.setImage(with: url)
            } else {
                self.thumbnailImageView.image = UIImage(named: "placeholder")
            }
        }

        viewModel.output.isLiked.bind { [weak self] liked in
            guard let self, self.bindToken == token else { return }
            self.setHeart(isLiked: liked)
        }
    }

    private func setHeart(isLiked: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let name = isLiked ? "heart.fill" : "heart"
        heartButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }

    private func setupUI() {
        contentView.backgroundColor = .black
        contentView.addSubview(cardView)
        [thumbnailImageView, heartButton, shopLabel, titleLabel, priceLabel].forEach { cardView.addSubview($0) }

        cardView.snp.makeConstraints { $0.edges.equalToSuperview() }

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
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(shopLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
}
