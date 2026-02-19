//
//  Observable.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/13/26.
//

import Foundation

final class Observable<T> {

    private var listener: ((T) -> Void)?

    var value: T {
        didSet { listener?(value) }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(action: @escaping () -> Void) {
        listener = { _ in action() }
        action()
    }

    func bindWithoutInitial(action: @escaping () -> Void) {
        listener = { _ in action() }
    }

    func bind(_ closure: @escaping (T) -> Void) {
        listener = closure
        closure(value) 
    }

    func bindWithoutInitial(_ closure: @escaping (T) -> Void) {
        listener = closure
    }
}
