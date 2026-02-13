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

        bindViewModel()
        viewModel.load()
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
        viewModel.output.recentKeywords.bind { [weak self] in
            guard let self else { return }
            self.recentSearches = self.viewModel.output.recentKeywords.value
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        viewModel.output.alertMessage.bindWithoutInitial { [weak self] in
            guard let self else { return }
            guard let msg = self.viewModel.output.alertMessage.value else { return }
            DispatchQueue.main.async {
                self.showAlert(message: msg)
            }
        }

        viewModel.output.route.bindWithoutInitial { [weak self] in
            guard let self else { return }
            guard let route = self.viewModel.output.route.value else { return }

            DispatchQueue.main.async {
                switch route {
                case .showSearchResult(let query):
                    self.searchBar.text = query
                    let vc = SearchResultViewController(query: query)
                    self.navigationController?.pushViewController(vc, animated: true)
                }

                self.viewModel.output.route.value = nil
            }
        }

        viewModel.output.searchText.bindWithoutInitial { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.searchBar.text = self.viewModel.output.searchText.value
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
        viewModel.didTapClearAll()
    }
}

extension ShoppingViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.didTapSearch(with: searchBar.text ?? "")
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

        cell.onDeleteTapped = { [weak self] in
            self?.viewModel.didTapDeleteRecent(at: indexPath.row)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRecent(at: indexPath.row)
    }
}
