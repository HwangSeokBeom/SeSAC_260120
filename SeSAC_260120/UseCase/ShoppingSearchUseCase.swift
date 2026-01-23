//
//  ShoppingSearchUseCase.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/23/26.
//

final class ShoppingSearchUseCase: ShoppingSearchUseCasing {
    
    private let service: NaverShoppingServicing
    
    private var currentQuery: String?
    private var currentSort: NaverSort = .sim
    private var paging = PagingState(pageSize: 30)
    
    init(service: NaverShoppingServicing = RealNaverShoppingService()) {
        self.service = service
    }
    
    func reset(
        query: String,
        sort: NaverSort,
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        currentQuery = query
        currentSort = sort
        
        request(reset: true, completion: completion)
    }
    
    func loadNext(
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        request(reset: false, completion: completion)
    }
    
    private func request(
        reset: Bool,
        completion: @escaping (Result<[NaverShoppingItem], NetworkError>) -> Void
    ) {
        guard let query = currentQuery, !query.isEmpty else {
            return
        }
        
        guard let request = paging.prepareRequest(shouldReset: reset) else {
            return
        }
        
        service.searchShopping(
            query: query,
            start: request.start,
            display: request.display,
            sort: currentSort.rawValue
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let pageItems):
                self.paging.didReceivePage(itemCount: pageItems.count)
                completion(.success(pageItems))
                
            case .failure(let error):
                self.paging.didFail()
                completion(.failure(error))
            }
        }
    }
}
