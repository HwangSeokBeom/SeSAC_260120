//
//  Observable.swift
//  SeSAC_260120
//
//  Created by Hwangseokbeom on 2/13/26.
//

import Foundation

final class Observable<T> {
    private var action: (() -> Void)?

    var value: T {
        didSet { action?() }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(action: @escaping () -> Void) {
        action()
        self.action = action
    }

    func bindWithoutInitial(action: @escaping () -> Void) {
        self.action = action
    }
}
