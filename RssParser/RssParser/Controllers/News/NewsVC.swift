import UIKit
import WebKit

final class NewsController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: - Properties
    public var rssAtribution: RssAttribution!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        webView.stopLoading()
    }
    
    //MARK: - Setups
    private func setupWebView() {
        
        if let newsUrl = rssAtribution.link, let url = URL(string: newsUrl) {
            
            webView.navigationDelegate = self
            getSource(fromUrl: newsUrl)
            load(baseURL: url)
        } else {
            
            openAlert()
        }
    }
    
    //MARK: - Load from html or url
    private func load(baseURL: URL) {
        
        if let html = rssAtribution.html {
            
            webView.loadHTMLString(html, baseURL: baseURL)
        } else {
            
            var webRequest = URLRequest(url: baseURL)
            webRequest.httpMethod = "GET"
            webView.load(webRequest)
        }
    }
    
    //MARK: - Get source
    private func getSource(fromUrl: String) {
        
        let splitTitles = fromUrl.split(separator: "/")
        self.title = String(splitTitles[1])
    }
    
    //MARK: - Open alert
    private func openAlert() {
        
        let alertController = UIAlertController(title: "Oops", message: "load webview failed", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (nil) in
            
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - WKNavigationDelegate
extension NewsController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("Finish load")
        
        webView.evaluateJavaScript("document.body.innerHTML") { (html, error) in
            
            guard let html = html as? String else {
                return
            }
            
            CoreDataManager.shared.rssAddHTML(rssAttribution: self.rssAtribution, html: html)
        }
    }
}
