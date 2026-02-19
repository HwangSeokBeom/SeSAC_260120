//
//  BaseViewModel.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/19/26.
//

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}
