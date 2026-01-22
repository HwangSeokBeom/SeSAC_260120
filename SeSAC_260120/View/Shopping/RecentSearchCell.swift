//
//  RecentSearchCell.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/22/26.
//
import UIKit
import SnapKit

final class RecentSearchCell: UITableViewCell {
    
    static let identifier = "RecentSearchCell"
    
    var onDeleteTapped: (() -> Void)?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray2
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray3
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray3
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(keywordLabel)
        contentView.addSubview(deleteButton)
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        keywordLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(deleteButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
        
        deleteButton.addTarget(self,
                               action: #selector(deleteButtonTapped),
                               for: .touchUpInside)
    }
    
    func configure(with keyword: String) {
        keywordLabel.text = keyword
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}
