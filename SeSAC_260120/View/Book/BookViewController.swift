//
//  BookViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/21/26.
//

import UIKit
import SnapKit

final class BookViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .minimal
        bar.placeholder = "브랜드, 상품, 프로필, 태그 등"
        bar.returnKeyType = .search
        bar.searchTextField.font = .systemFont(ofSize: 16)
        bar.searchTextField.clearButtonMode = .whileEditing
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
}

extension BookViewController: ViewDesignProtocol {
    func configureView() {
        view.backgroundColor = .black
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        navigationItem.title = "도봉러의 쇼핑쇼핑"
        
        searchBar.delegate = self
    }
    
    func configureHierarchy() {
        view.addSubview(searchBar)
    }
    
    func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

extension BookViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        let vc = SearchResultViewController()
        vc.query = query
        navigationController?.pushViewController(vc, animated: true)
    }
}
