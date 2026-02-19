//
//  ShoppingViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import UIKit
import SnapKit

final class ShoppingViewController: UIViewController {

    private let viewModel: ShoppingViewModel
    private var recentSearches: [String] = []

    private let input = ShoppingViewModel.Input(
        searchText: Observable(""),
        didTapSearch: Observable(()),
        didSelectRecentIndex: Observable(0),
        didTapDeleteRecentIndex: Observable(0),
        didTapClearAll: Observable(())
    )
    private var output: ShoppingViewModel.Output!

    init(viewModel: ShoppingViewModel = ShoppingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .minimal
        bar.placeholder = "브랜드, 상품, 프로필, 태그 등"
        bar.returnKeyType = .search
        bar.searchTextField.font = .systemFont(ofSize: 16)
        bar.searchTextField.clearButtonMode = .whileEditing
        return bar
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.tableFooterView = UIView()
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureHierarchy()
        configureLayout()

        output = viewModel.transform(input)
        bindViewModel()
    }
}

extension ShoppingViewController: ViewDesignProtocol {

    func configureView() {
        view.backgroundColor = .black

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        navigationItem.title = "도봉러의 쇼핑쇼핑"

        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            RecentSearchCell.self,
            forCellReuseIdentifier: RecentSearchCell.identifier
        )
    }

    func configureHierarchy() {
        [searchBar, tableView].forEach { view.addSubview($0) }
    }

    func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

private extension ShoppingViewController {

    func bindViewModel() {
        output.recentKeywords.bind { [weak self] keywords in
            guard let self else { return }
            self.recentSearches = keywords
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        output.alertMessage.bindWithoutInitial { [weak self] msg in
            guard let self else { return }
            guard let msg else { return }
            DispatchQueue.main.async {
                self.showAlert(message: msg)
            }
        }

        output.route.bindWithoutInitial { [weak self] route in
            guard let self else { return }
            guard let route else { return }

            DispatchQueue.main.async {
                switch route {
                case .showSearchResult(let query):
                    self.searchBar.text = query
                    let vc = SearchResultViewController(query: query)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            self.output.route.value = nil
        }

        output.searchText.bindWithoutInitial { [weak self] text in
            guard let self else { return }
            DispatchQueue.main.async {
                self.searchBar.text = text
            }
        }
    }

    func showAlert(title: String = "알림", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    @objc func didTapClearAll() {
        input.didTapClearAll.value = ()
    }
}

extension ShoppingViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        input.searchText.value = searchBar.text ?? ""
        input.didTapSearch.value = ()
    }
}

extension ShoppingViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        recentSearches.isEmpty ? 0.01 : 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !recentSearches.isEmpty else { return nil }

        let container = UIView()
        container.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = "최근 검색어"
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .lightGray

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("전체 삭제", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.addTarget(self, action: #selector(didTapClearAll), for: .touchUpInside)

        container.addSubview(titleLabel)
        container.addSubview(clearButton)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        return container
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentSearches.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecentSearchCell.identifier,
            for: indexPath
        ) as? RecentSearchCell else {
            return UITableViewCell()
        }

        let keyword = recentSearches[indexPath.row]
        cell.configure(with: keyword)
        cell.onDeleteTapped = { [weak self, weak cell] in
            guard let self, let cell,
                  let currentIndexPath = tableView.indexPath(for: cell) else { return }
            self.input.didTapDeleteRecentIndex.value = currentIndexPath.row
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        input.didSelectRecentIndex.value = indexPath.row
    }
}
