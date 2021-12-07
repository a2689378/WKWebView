//
//  WKWebView.swift
//  WKWebView
//
//  Created by 何常凱 on 2021/11/23.
//

import UIKit
import WebKit

extension WKWebView {
    func load(_ string: String) {
        if let url = URL(string: string) {
            load(URLRequest(url: url))
        }
    }
}
