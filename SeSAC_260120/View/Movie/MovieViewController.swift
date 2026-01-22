//
//  MovieViewController.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/20/26.
//

import UIKit
import SnapKit

final class MovieViewController: UIViewController {
    
    private var movies: [Movie] = []
    
    private let movieService: MovieServicing
    
    init(service: MovieServicing = RealMovieService()) {
        self.movieService = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "20200401"
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.textColor = .label
        return textField
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("검색", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = 56
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(MovieTableViewCell.self,
                           forCellReuseIdentifier: MovieTableViewCell.identifier)
    }
}

extension MovieViewController: ViewDesignProtocol {
    
    func configureHierarchy() {
        [searchTextField, underlineView, searchButton, tableView]
            .forEach { view.addSubview($0) }
    }
    
    func configureLayout() {
        
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.trailing.equalTo(searchButton.snp.leading).offset(-16)
            make.centerY.equalTo(searchButton.snp.centerY)
            make.height.equalTo(32)
        }
        
        underlineView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(6)
            make.leading.trailing.equalTo(searchTextField)
            make.height.equalTo(2)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(underlineView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureView() {
        view.backgroundColor = .white
        title = "영화 순위"
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        let yesterday = yesterdayString()
            searchTextField.text = yesterday
            fetchBoxOffice(targetDate: yesterday)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func yesterdayString() -> String {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        return formatter.string(from: yesterday)
    }
    
    private func showAlert(title: String = "알림", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func searchButtonTapped() {
        view.endEditing(true)
        
        let dateString = searchTextField.text ?? ""
        
        guard dateString.count == 8, Int(dateString) != nil else {
            showAlert(message: MovieAlert.invalidDate.message)
            return
        }
        
        fetchBoxOffice(targetDate: dateString)
    }
}

extension MovieViewController {
    
    private func fetchBoxOffice(targetDate: String) {
        MovieService.fetchDailyBoxOffice(date: targetDate) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    if movies.isEmpty {
                        self.movies = []
                        self.tableView.reloadData()
                        self.showAlert(message: MovieAlert.empty.message)
                        return
                    }
                    
                    self.movies = movies
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.showAlert(message: MovieAlert.failure(error).message)
                }
            }
        }
    }
}

extension MovieViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieTableViewCell.identifier,
            for: indexPath
        ) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}
