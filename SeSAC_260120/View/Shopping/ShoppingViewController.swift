
//
//  BookViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import UIKit
import SnapKit

final class ShoppingViewController: UIViewController {
    
    private let shoppingService: NaverShoppingServicing
    private let userDefaultsManager: UserDefaultsManaging
    private var recentSearches: [String] = []
    
    init(
        service: NaverShoppingServicing = RealNaverShoppingService(),
        userDefaultsManager: UserDefaultsManaging = UserDefaultsManager()
    ) {
        self.shoppingService = service
        self.userDefaultsManager = userDefaultsManager
        super.init(nibName: nil, bundle: nil)
    }
    
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
        loadRecentSearches()
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
        tableView.register(RecentSearchCell.self,
                           forCellReuseIdentifier: RecentSearchCell.identifier)
    }
    
    func configureHierarchy() {
        [ searchBar, tableView ].forEach { view.addSubview($0)
        }
    }
    
    func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            
            tableView.snp.makeConstraints {
                $0.top.equalTo(searchBar.snp.bottom).offset(8)
                $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
}

extension ShoppingViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard var query = searchBar.text else {
            showAlert(message: "검색어를 입력해주세요.")
            return
        }
        
        query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            showAlert(message: "검색어를 입력해주세요.")
            return
        }
        
        guard query.count >= 2 else {
            showAlert(message: "검색어를 두 글자 이상 입력해주세요.")
            return
        }
        
        let alphabet = CharacterSet.alphanumerics
        let hangul = CharacterSet(charactersIn: "가"..."힣")
        let allowed = alphabet.union(hangul)
        
        if query.rangeOfCharacter(from: allowed) == nil {
            showAlert(message: "유효한 검색어를 입력해주세요.")
            return
        }
        
        performSearch(with: query)
    }
}

private extension ShoppingViewController {
    func showAlert(title: String = "알림", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

extension ShoppingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return recentSearches.isEmpty ? 0.01 : 44
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
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
        clearButton.addTarget(self,
                              action: #selector(clearAllRecentSearches),
                              for: .touchUpInside)
        
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
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
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
            self?.removeRecentSearch(at: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let keyword = recentSearches[indexPath.row]
        searchBar.text = keyword
        performSearch(with: keyword)
    }
}

private extension ShoppingViewController {
    
    func performSearch(with query: String) {
        saveRecentSearch(query)
        
        let vc = SearchResultViewController()
        vc.query = query
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadRecentSearches() {
        recentSearches = userDefaultsManager.loadStringArray(forKey: .recentSearchKeywords)
        tableView.reloadData()
    }
    
    func saveRecentSearch(_ keyword: String) {
        var list = recentSearches
        
        if let index = list.firstIndex(of: keyword) {
            list.remove(at: index)
        }
        list.insert(keyword, at: 0)
        
        if list.count > 20 {
            list = Array(list.prefix(20))
        }
        
        recentSearches = list
        userDefaultsManager.saveStringArray(list, forKey: .recentSearchKeywords)
        tableView.reloadData()
    }
    
    func removeRecentSearch(at index: Int) {
        guard recentSearches.indices.contains(index) else { return }
        recentSearches.remove(at: index)
        userDefaultsManager.saveStringArray(recentSearches, forKey: .recentSearchKeywords)
        tableView.reloadData()
    }
    
    @objc func clearAllRecentSearches() {
        recentSearches.removeAll()
        userDefaultsManager.remove(forKey: .recentSearchKeywords)
        tableView.reloadData()
    }
}
