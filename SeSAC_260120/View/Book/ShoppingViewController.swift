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
    
    init(service: NaverShoppingServicing = RealNaverShoppingService()) {
        self.shoppingService = service
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
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
        
        let vc = SearchResultViewController()
        vc.query = query
        navigationController?.pushViewController(vc, animated: true)
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
