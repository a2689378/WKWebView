//
//  ViewController.swift
//  WKWebView
//
//  Created by 何常凱 on 2021/11/23.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var spinner: UIActivityIndicatorView!
    
    //自定义根试图
    override func loadView() {
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "user")
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setSpinner()
        
        webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        //handleHTMLString()
        //观察者进度条KVO
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    func setSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        spinner.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7980626593)
        spinner.layer.cornerRadius = 10
        spinner.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 80).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func handleHTMLString() {
        let html = """
            <!DOCTYPE html>
            <html lang="en">
                <head>
                    <meta charset="UTF-8">
                        <title>Lebus</title>
                        </head>
                <body>
                    <div style="text-align: center;font-size: 80px;margin-top: 350px">Lebus的iOS教程</div>
                </body>
            </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    //直接加载html文件
    func handleHTMLFile() {
        let url = Bundle.main.url(forResource: "HomePage", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    func handleJS() {
        webView.evaluateJavaScript("document.body.offsetHeight") { (res, error) in
            print(res)
        }
    }
    
    func takeSnapshot() {
        //let config = WKSnapshotConfiguration()
       //config.rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        webView.takeSnapshot(with: nil) { image, err in
            guard let image = image else {return}
            print(image.size)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            print(webView.estimatedProgress)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "user" {
            print(message.body)
        }
    }
    
}

//转出web弹出框为原生
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { _ in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = defaultText
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(alert.textFields?.last?.text)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        guard let url = navigationAction.request.url else {
//            return
//        }
//        if url.host == "www.google.com" {
//            decisionHandler(.allow)
//        } else {
//            UIApplication.shared.open(url)
//            decisionHandler(.cancel)
//        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
        spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let httpResponse = navigationResponse.response as? HTTPURLResponse,  httpResponse.statusCode == 200{
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        handleJS()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }

}


