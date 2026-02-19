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

    private let viewModel: SearchResultViewModel

    private var items: [SearchResultCellViewModel] = []

    private let input = SearchResultViewModel.Input(
        viewDidLoad: Observable(()),
        didTapSort: Observable(.sim),
        didReachBottom: Observable(())
    )
    private var output: SearchResultViewModel.Output!

    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(
        query: String,
        searchUseCase: ShoppingSearchUseCasing = ShoppingSearchUseCase()
    ) {
        let vm = SearchResultViewModel(query: query, useCase: searchUseCase)
        self.init(viewModel: vm)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let resultCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "0개의 검색 결과"
        return label
    }()

    private let accuracyButton: UIButton = SearchResultViewController.makeSortButton(title: "정확도", isSelected: true)
    private let dateButton: UIButton = SearchResultViewController.makeSortButton(title: "날짜순")
    private let highPriceButton: UIButton = SearchResultViewController.makeSortButton(title: "가격높은순")
    private let lowPriceButton: UIButton = SearchResultViewController.makeSortButton(title: "가격낮은순")

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

        output = viewModel.transform(input)
        bindViewModel()

        input.viewDidLoad.value = ()
    }
}

extension SearchResultViewController: ViewDesignProtocol {

    func configureView() {
        view.backgroundColor = .black

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        resultCountLabel.text = "0개의 검색 결과"

        accuracyButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        highPriceButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        lowPriceButton.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
    }

    func configureHierarchy() {
        [resultCountLabel, sortStackView, collectionView].forEach { view.addSubview($0) }
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

    func bindViewModel() {
        output.title.bind { [weak self] title in
            guard let self else { return }
            DispatchQueue.main.async {
                self.navigationItem.title = title
            }
        }

        output.cellViewModels.bind { [weak self] (newItems: [SearchResultCellViewModel]) in
            guard let self else { return }
            self.items = newItems

            DispatchQueue.main.async {
                self.collectionView.reloadData()

                if !newItems.isEmpty {
                    self.collectionView.scrollToItem(
                        at: IndexPath(item: 0, section: 0),
                        at: .top,
                        animated: false
                    )
                }
            }
        }

        output.resultCountText.bind { [weak self] text in
            guard let self else { return }
            DispatchQueue.main.async {
                self.resultCountLabel.text = text
            }
        }

        output.selectedSort.bind { [weak self] sort in
            guard let self else { return }
            DispatchQueue.main.async {
                self.applySortSelectionUI(sort: sort)
            }
        }

        output.errorMessage.bindWithoutInitial { [weak self] msg in
            guard let self else { return }
            guard let msg else { return }
            print(msg)
        }
    }

    func applySortSelectionUI(sort: NaverSort) {
        let selectedButton: UIButton
        switch sort {
        case .sim:  selectedButton = accuracyButton
        case .date: selectedButton = dateButton
        case .dsc:  selectedButton = highPriceButton
        case .asc:  selectedButton = lowPriceButton
        }
        updateSortButtonSelection(selected: selectedButton)
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
        let sort: NaverSort
        switch sender {
        case accuracyButton:  sort = .sim
        case dateButton:      sort = .date
        case highPriceButton: sort = .dsc
        case lowPriceButton:  sort = .asc
        default:              sort = .sim
        }
        input.didTapSort.value = sort
    }
}

extension SearchResultViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging || scrollView.isDecelerating else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if contentHeight > height,
           offsetY > contentHeight - height * 1.5 {
            input.didReachBottom.value = ()
        }
    }
}

extension SearchResultViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchResultCell.identifier,
            for: indexPath
        ) as? SearchResultCell else {
            return UICollectionViewCell()
        }

        let vm = items[indexPath.item]
        cell.configure(with: vm)
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
