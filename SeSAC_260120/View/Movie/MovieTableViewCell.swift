//
//  MovieTableViewCell.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import UIKit
import SnapKit

final class MovieTableViewCell: UITableViewCell {
    
    static let identifier = "MovieTableViewCell"
    
    private let rankContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHierarchy()
        setupLayout()
        setupStyle()
    }
    
    private func setupHierarchy() {
        contentView.addSubview(rankContainerView)
        rankContainerView.addSubview(rankLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
    }
    
    private func setupLayout() {
        rankContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        rankLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(rankContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func configure(with movie: Movie) {
        rankLabel.text = "\(movie.rank)"
        titleLabel.text = movie.title
        dateLabel.text = movie.date
    }
}
