//
//  PicsumViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import UIKit
import SnapKit
import Kingfisher

final class PicsumViewController: UIViewController {
    
    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("랜덤 이미지 불러오기", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.text = "작가: "
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let resolutionLabel: UILabel = {
        let label = UILabel()
        label.text = "해상도: "
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
        setupActions()
    }
    
    private func setupActions() {
        loadButton.addTarget(self, action: #selector(loadTapped), for: .touchUpInside)
    }
    
    @objc private func loadTapped() {
        fetchRandomPhoto()
    }
}

extension PicsumViewController: ViewDesignProtocol {
    
    func configureHierarchy() {
        
        [loadButton, imageView, authorLabel, resolutionLabel].forEach{ view.addSubview($0) }
    }
    
    func configureLayout() {
        
        loadButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 220, height: 48))
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(loadButton.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(imageView.snp.width).multipliedBy(0.66)
        }

        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(24)
        }

        resolutionLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
    func configureView() {
        view.backgroundColor = .white
    }
}

extension PicsumViewController {
    
    func fetchRandomPhoto() {
        let randomId = Int.random(in: 0...1000)
        let url = "https://picsum.photos/id/\(randomId)/info"
        
        NetworkManager.shared.request(url) { [weak self] (result: Result<PicsumPhoto, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photo):
                self.updateUI(with: photo)
                
            case .failure(let error):
                print("Error:", error)
            }
        }
    }
    
    func updateUI(with photo: PicsumPhoto) {
        DispatchQueue.main.async {
            self.authorLabel.text = "작가: \(photo.author)"
            self.resolutionLabel.text = "해상도: \(photo.width) x \(photo.height)"
            self.loadImage(id: photo.id)
        }
    }
    
    func loadImage(id: String) {
        let imageURL = "https://picsum.photos/id/\(id)/600/400"
        
        imageView.kf.indicatorType = .activity
        
        if let url = URL(string: imageURL) {
            imageView.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}
