//
//  ViewController.swift
//  Royal Frolics (WebView)
//
//  Created by MD SHAHNAWAZUL HAQUE on 20/11/20.
//  Copyright © 2020 Royal Frolics. All rights reserved.
// heeeeee

import UIKit
import WebKit
import CFNetwork
let reachability = try! Reachability()

class ViewController:UIViewController , WKNavigationDelegate {
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    public typealias BoolBlock = (_ boolen: Bool) -> Void
    public typealias ReceiveScriptMessageBlock = (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void
    
    public struct WebViewConfig {
        /// 弹窗确定按钮的文字
        public static var alertConfirmTitle: String = "Done"
        /// 弹窗取消按钮的文字
        public static var alertCancelTitle: String = "Cancel"
        /// 进度条完成部分进度的颜色(默认蓝)
        public static var progressTintColor = UIColor(red:1.0, green:0.84, blue:0.37, alpha:1)
        /// 进度条总进度的颜色
        public static var progressTrackTintColor = UIColor(red:1.0, green:0.84, blue:0.37, alpha:0.5)
    }

    
    var strLabel = UILabel()
   let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let loadingTextLabel = UILabel()
   
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var webView: WKWebView!
    
    var refController:UIRefreshControl = UIRefreshControl()
    
    
    
    /// loading the html string by append html predefine content
    /// - Parameter htmlString: html string
    /// - Parameter appendingHtmlFormat: whether append html base format
    /// - Parameter delegate: height of webView observer
    public func setupHtmlString(_ htmlString: String, appendingHtmlFormat: Bool = false) {
        if appendingHtmlFormat {
            self.htmlString = htmlString
        } else {
            self.htmlString = htmlString
        }
    }
    
    /// access url string
    public var urlString: String? {
        didSet {
            guard let urlString = urlString, let url = URL(string: urlString) else {
                fatalError("URL can't be nil")
            }
            var request = URLRequest(url: url)
            request.addValue("skey=skeyValue", forHTTPHeaderField: "Cookie")
            webView.load(request)
        }
    }
    
    /// access html string
    public var htmlString: String? {
        didSet {
            guard let htmlString = htmlString else {
                fatalError("htmlString can't be nil")
            }
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    /// access urlRequest
    public var urlRequest: URLRequest? {
        didSet {
            guard let urlRequest = urlRequest else {
                fatalError("urlRequest can't be nil")
            }
            webView.load(urlRequest)
        }
    }
    
    /// whether show progressView of loading
    open var isShowProgressView: Bool {
        return true
    }
    
    /// whether show title of webView content
    open var isShowTitle: Bool {
        return false
    }
    
    /// progressView's tintColor
    public var progressTintColor: UIColor = WebViewConfig.progressTintColor
    /// progressView's track tintColor
    public var progressTrackTintColor: UIColor = WebViewConfig.progressTrackTintColor
    /// alert confirm title of runJavaScriptAlertPanelWithMessage, default is  "OK"，can setup at WebViewConfig.alertConfirmTitle
    public var alertConfirmTitle: String = WebViewConfig.alertConfirmTitle
    /// alert confirm title of runJavaScriptAlertPanelWithMessage, default is  "Cancel"，can setup at WebViewConfig.alertCancelTitle
    public var alertCancelTitle: String = WebViewConfig.alertCancelTitle
    
    
    
    public lazy private(set) var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = progressTrackTintColor
        progressView.tintColor = progressTintColor
        return progressView
    }()
    
    private var loadingObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    private var progressObservation: NSKeyValueObservation?
    
    deinit {
        loadingObservation = nil
        titleObservation = nil
        progressObservation = nil
    }
    
    
    override func viewDidLoad() {
        
        
        
        webView = WKWebView(frame: CGRect.zero)
        webView.navigationDelegate = self
      webView.uiDelegate = self
 
        
       
        let userContentController = WKUserContentController()
        let cookieScript = WKUserScript(source: "document.cookie = 'skey=skeyValue';",
                                        injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.minimumFontSize = 1
        configuration.preferences.javaScriptEnabled = true
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController = userContentController
        
       
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsBackForwardNavigationGestures = true
        
        
        // Change url 
        
        webView.load(URLRequest(url: URL(string: "https://royalfrolics.com")!))
        setBackground()
        addObservers()
        setupUI()
        
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via wifi")
            }else{
                print("Reachable via cellular")
            }
            
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.showAlert()
            
        }
        do{
            try reachability.startNotifier()
        }catch{
            print("unable to start notifier")
        }
        
    }

    
    func showAlert(){
        
        let alert = UIAlertController(title: "no Internet", message: "This App Requires wifi/internet connection!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {_ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        }
    
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isShowProgressView {
            let progressViewHeight: CGFloat = 2
            progressView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: progressViewHeight)
            webView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        } else {
            webView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        }
    }

    
    
    func setBackground() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red:0.38, green:0.03, blue:0.22, alpha:1)
        webView.scrollView.backgroundColor = UIColor(red:0.38, green:0.03, blue:0.22, alpha:0.7)
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            
            
            strLabel = UILabel(frame: CGRect(x: 55, y: 0, width: 400, height: 66))
            strLabel.text = "Please Wait. Checking Internet Connection..."
            strLabel.font = UIFont(name: "Avenir Light", size: 12)
            
           
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
           
            effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 300, height: 66)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
            indicator = UIActivityIndicatorView(style: .white)
            indicator.frame = CGRect(x: 0, y: 0, width: 66, height: 66)
            indicator.startAnimating()
            effectView.contentView.addSubview(indicator)
            effectView.contentView.addSubview(strLabel)
            indicator.transform = CGAffineTransform(scaleX: 1.4, y: 1.4);
            effectView.center = webView.center
            view.addSubview(effectView)
            
            
        } else {
            strLabel.removeFromSuperview()
             effectView.removeFromSuperview()
            indicator.removeFromSuperview()
            indicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
       
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if url.description.lowercased().range(of: "http://") != nil ||
                url.description.lowercased().range(of: "https://") != nil ||
                url.description.lowercased().range(of: "mailto:") != nil {
                UIApplication.shared.openURL(url)
            }
        }
        return nil
    }
    
    
    private func webView(webView: WKWebView!, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError!) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
   
    
}



// MARK: - UI
private extension ViewController {
    func setupUI() {
        view.addSubview(webView)
        if isShowProgressView {
            view.addSubview(progressView)
        }
    }
    
    func showProgressView() {
        let originY = webView.scrollView.adjustedContentInset.top
        progressView.frame.origin.y = originY
        progressView.isHidden = false
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
    }
    
    func hideProgressView() {
        progressView.isHidden = true
        progressView.setProgress(0, animated: false)
    }
}

// MARK: - Action
extension ViewController {
    /// back to last page
    ///
    /// - Parameter completion: whether can back to prefix page
    func goBack(completion: BoolBlock? = nil) {
        if webView.canGoBack {
            webView.goBack()
            completion?(webView.canGoBack)
        }
        completion?(false)
    }
    
    /// go to next oage
    ///
    /// - Parameter completion: whether can go to next page
    func goForward(completion: BoolBlock? = nil) {
        if webView.canGoForward {
            webView.goForward()
            completion?(webView.canGoForward)
        }
        completion?(false)
    }
    
    /// reload the webView
    func reload() {
        webView.reload()
    }
}

// MARK: - Function
private extension ViewController {
    func addObservers() {
        loadingObservation = webView.observe(\WKWebView.isLoading) { [weak self] (_, _) in
            guard let self = self else { return }
            if !self.webView.isLoading {
                self.hideProgressView()
            }
        }
        titleObservation = webView.observe(\WKWebView.title) { [weak self] (webView, _) in
            guard let self = self, self.isShowTitle else { return }
            self.title = self.webView.title
        }
        progressObservation = webView.observe(\WKWebView.estimatedProgress) { [weak self] (_, _) in
            guard let self = self else { return }
            self.showProgressView()
        }
    }
}

// MARK: - WKUIDelegate
extension ViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Royal Frolics", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertConfirmTitle, style: .default, handler: { (_) in
            completionHandler()
        }))
        present(alert, animated: false, completion: nil)
    }
    
    public func webView(_ webView: WKWebView,
                        runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Royal Frolics", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertConfirmTitle, style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: alertCancelTitle, style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        present(alert, animated: false, completion: nil)
    }
    
    public func webView(_ webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "Royal Frolics", message: defaultText, preferredStyle: .alert)
        alert.addTextField { (textFiled) in
            textFiled.textColor = .red
        }
        alert.addAction(UIAlertAction(title: alertConfirmTitle, style: .default, handler: { (_) in
            completionHandler(alert.textFields![0].text!)
        }))
        present(alert, animated: false, completion: nil)
    }
}



public extension UIViewController {
    // convenient method: push to WebViewController, and loading url
    func pushToWebByLoadingURL(_ url: String, title: String? = nil) {
        let webViewController = ViewController()
        webViewController.title = title
        webViewController.urlString = url
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // convenient method: push to WebViewController, and loading html string
    func pushToWebByHTMLString(_ html: String, title: String? = nil) {
        let webViewController = ViewController()
        webViewController.title = title
        webViewController.setupHtmlString(html, appendingHtmlFormat: true)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

public extension String {
    func appendingHtmlFormat(contentWidth: CGFloat) -> String {
        let html = """
        <html>
        <head>
        <meta name="viewport", content="width=\(contentWidth), initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no\">
        <style>
        body { font-size: 100%; text-align: justify;}
        p { margin:0 !important; }
        span { line-height:normal !important }
        table { width: 100% !important;}
        img { max-width:100%; width: 100%; height:auto; padding:0; border:0; margin:0; vertical-align:bottom;}
        </style>
        </head>
        <body>
        \(self)
        </body>
        </html>
        """
        return html
    }
}

extension UIView {
    /// 递归查找子类 UIView
    ///
    /// - Parameter name: UIView 的类名称
    /// - Returns: 找到的 UIView
    func recursiveFindSubview(of name: String) -> UIView? {
        for view in subviews {
            if view.isKind(of: NSClassFromString(name)!) {
                return view
            }
        }
        for view in subviews {
            if let tempView = view.recursiveFindSubview(of: name) {
                return tempView
            }
        }
        return nil
    }
}

extension NSObject {
    /// Sets an associated value for a given object using a weak reference to the associated object.
    /// **Note**: the `key` underlying type must be String.
    func associate(assignObject object: Any?, forKey key: UnsafeRawPointer) {
        let strKey: String = convertUnsafePointerToSwiftType(key)
        willChangeValue(forKey: strKey)
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_ASSIGN)
        didChangeValue(forKey: strKey)
    }
    
    /// Sets an associated value for a given object using a strong reference to the associated object.
    /// **Note**: the `key` underlying type must be String.
    func associate(retainObject object: Any?, forKey key: UnsafeRawPointer) {
        let strKey: String = convertUnsafePointerToSwiftType(key)
        willChangeValue(forKey: strKey)
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        didChangeValue(forKey: strKey)
    }
    
    /// Sets an associated value for a given object using a copied reference to the associated object.
    /// **Note**: the `key` underlying type must be String.
    func associate(copyObject object: Any?, forKey key: UnsafeRawPointer) {
        let strKey: String = convertUnsafePointerToSwiftType(key)
        willChangeValue(forKey: strKey)
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        didChangeValue(forKey: strKey)
    }
    
    /// Returns the value associated with a given object for a given key.
    /// **Note**: the `key` underlying type must be String.
    func associatedObject(forKey key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
    
    func convertUnsafePointerToSwiftType<T>(_ value: UnsafeRawPointer) -> T {
        return value.assumingMemoryBound(to: T.self).pointee
    }
}

extension UIScrollView {
    var autualContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        } else {
            return contentInset
        }
    }
}


   
    






