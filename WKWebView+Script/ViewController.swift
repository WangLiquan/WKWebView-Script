//
//  ViewController.swift
//  WKWebView+Script
//
//  Created by Ethan.Wang on 2018/9/10.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    lazy var webView: WKWebView = {
        ///偏好设置
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.selectionGranularity = WKSelectionGranularity.character
        configuration.userContentController = WKUserContentController()
        // 给webview与swift交互起名字，webview给swift发消息的时候会用到
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "logger")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "redResponse")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "blueResponse")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "greenResponse")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "yellowResponse")

        var webView = WKWebView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: UIScreen.main.bounds.width,
                                              height: UIScreen.main.bounds.height),
                                configuration: configuration)
        // 让webview翻动有回弹效果
        webView.scrollView.bounces = false
        // 只允许webview上下滚动
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        return webView
    }()
    ///加载本地html文件
    let HTML = try! String(contentsOfFile: Bundle.main.path(forResource: "problem", ofType: "html")!,
                           encoding: String.Encoding.utf8)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.loadHTMLString(HTML, baseURL: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }


    func redRequest(){
        print("Swift log:没有从JS接收参数")
    }
    func blueRequest(string: String){
        print("Swift log:\(string),从JS接收字符串")
    }
    func greenRequest(int: Int){
        print("Swift log:\(int),从JS接收Int")
    }
    func yellowRequest(array: [String]){
        for str in array{
            print("Swift log:\(str),从JS接收Array")
        }
    }

}

extension ViewController: WKNavigationDelegate{
    ///在网页加载完成时调用js方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("sayHello('js你好,我是从Swift传来的')", completionHandler: nil)
    }
}

extension ViewController: WKScriptMessageHandler{
    ///接收js调用方法
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        ///在控制台中打印html中console.log的内容,方便调试
        let body = message.body
        if message.name == "logger" {
            print("JS log:\(body)")
            return
        }
        ///message.name是约定好的方法名,message.body是携带的参数
        switch message.name {
        case "redResponse":
            ///不接收参数时直接不处理message.body即可,不用管Html传了什么
            redRequest()
        case "blueResponse":
            blueRequest(string: message.body as! String)
        case "greenResponse":
            greenRequest(int: message.body as! Int)
        case "yellowResponse":
            yellowRequest(array: message.body as! [String])
        default:
            break
        }
    }
}
