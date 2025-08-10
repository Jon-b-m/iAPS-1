import SwiftUI
import WebKit

/// Opens a WKWebView on the given `url` in a new page
public struct WebView: UIViewRepresentable {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIView(context _: UIViewRepresentableContext<WebView>) -> WKWebView {
        let webview = WKWebView()

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)

        return webview
    }

    public func updateUIView(_ webview: WKWebView, context _: UIViewRepresentableContext<WebView>) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
}
