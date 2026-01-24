//
//  PagingState.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 1/23/26.
//


import Foundation

struct PagingState {
    let pageSize: Int
    
    private(set) var nextStart: Int = 1
    private(set) var isLoading: Bool = false
    private(set) var hasMore: Bool = true
    
    var canLoadMore: Bool {
        hasMore && !isLoading
    }
    
    
    init(pageSize: Int = 30) {
        self.pageSize = pageSize
    }
    
    mutating func reset() {
        nextStart = 1
        isLoading = false
        hasMore = true
    }
    
    mutating func prepareRequest(shouldReset: Bool) -> (start: Int, display: Int)? {
        if shouldReset {
            reset()
        }
        
        guard !isLoading, hasMore else {
            return nil
        }
        
        isLoading = true
        return (start: nextStart, display: pageSize)
    }
    
    mutating func didReceivePage(itemCount: Int) {
        isLoading = false
        
        if itemCount < pageSize {
            hasMore = false
        } else {
            nextStart += pageSize
        }
    }
    
    mutating func didFail() {
        isLoading = false
    }
}
