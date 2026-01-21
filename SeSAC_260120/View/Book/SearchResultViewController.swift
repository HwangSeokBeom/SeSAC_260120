//
//  SearchResultViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import UIKit
import SnapKit
import Kingfisher
import Alamofire

final class SearchResultViewController: UIViewController {
    
    var query: String?
    
    private var items: [NaverShoppingItem] = []
    
    private let resultCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "0개의 검색 결과"
        return label
    }()
    
    private lazy var accuracyButton: UIButton = SearchResultViewController.makeSortButton(title: "정확도", isSelected: true)
    private lazy var dateButton: UIButton = SearchResultViewController.makeSortButton(title: "날짜순")
    private lazy var highPriceButton: UIButton = SearchResultViewController.makeSortButton(title: "가격높은순")
    private lazy var lowPriceButton: UIButton = SearchResultViewController.makeSortButton(title: "가격낮은순")
    
    private lazy var sortStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            accuracyButton,
            dateButton,
            highPriceButton,
            lowPriceButton
        ])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
        
        fetchShopping(sort: "sim")
    }
}

extension SearchResultViewController: ViewDesignProtocol {
    func configureView() {
        view.backgroundColor = .black
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        navigationItem.title = query ?? "검색 결과"

        resultCountLabel.text = "0개의 검색 결과"
        
        accuracyButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        highPriceButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        lowPriceButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
    }
    
    func configureHierarchy() {
        
        [resultCountLabel, sortStackView, collectionView ].forEach { view.addSubview($0) }
    }
    
    func configureLayout() {
        resultCountLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().inset(16)
        }
        
        sortStackView.snp.makeConstraints { make in
            make.top.equalTo(resultCountLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(32)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(sortStackView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

private extension SearchResultViewController {
    
    static func makeSortButton(title: String, isSelected: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        
        if isSelected {
            applySelectedStyle(to: button)
        } else {
            applyDeselectedStyle(to: button)
        }
        
        return button
    }
    
    static func applySelectedStyle(to button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    static func applyDeselectedStyle(to button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
    }
    
    func updateSortButtonSelection(selected: UIButton) {
        let buttons = [accuracyButton, dateButton, highPriceButton, lowPriceButton]
        buttons.forEach { button in
            if button === selected {
                SearchResultViewController.applySelectedStyle(to: button)
            } else {
                SearchResultViewController.applyDeselectedStyle(to: button)
            }
        }
    }
    
    @objc func didTapSortButton(_ sender: UIButton) {
        var sort: String = "sim"
        
        switch sender {
        case accuracyButton:
            sort = "sim"      // 정확도
        case dateButton:
            sort = "date"     // 날짜순
        case highPriceButton:
            sort = "dsc"      // 가격 높은 순
        case lowPriceButton:
            sort = "asc"      // 가격 낮은 순
        default:
            break
        }
        
        updateSortButtonSelection(selected: sender)
        fetchShopping(sort: sort)
    }
    
    func fetchShopping(sort: String) {
        guard let query = query, !query.isEmpty else { return }
        
        NaverShoppingService.searchShopping(
            query: query,
            start: 1,
            display: 40,
            sort: sort
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let items):
                self.items = items
                DispatchQueue.main.async {
                    self.resultCountLabel.text = "\(items.count)개의 검색 결과"
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("네이버 쇼핑 에러:", error)
                DispatchQueue.main.async {
                    self.items = []
                    self.resultCountLabel.text = "0개의 검색 결과"
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension SearchResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.identifier,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let inset: CGFloat = 8
        let spacing: CGFloat = 8
        let totalSpacing = inset * 2 + spacing
        let width = (collectionView.bounds.width - totalSpacing) / 2
        
        let height = width * 1.25
        return CGSize(width: width, height: height)
    }
}
