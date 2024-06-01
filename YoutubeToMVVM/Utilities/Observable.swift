//
//  Observable.swift
//  YoutubeViewController
//
//  Created by Lydia Lu on 2024/6/1.
//

import Foundation

// 原生觀察者綁定


class Observable <T> {
    
    typealias Helper =  (T) -> Void
    var helper:Helper?
    
    var value:T {
        didSet {
            helper?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    // 更改畫面值時,呼叫的方法
    func bind (completion: @escaping Helper) {
        self.helper = completion
    }
}
