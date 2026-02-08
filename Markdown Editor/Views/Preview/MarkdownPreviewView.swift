//
//  MarkdownPreviewView.swift
//  Markdown Editor
//
//  Created by ahammock on 2/7/26.
//

import SwiftUI
import WebKit

/// WebView-based Markdown preview renderer
struct MarkdownPreviewView: View {
    let html: String
    
    var body: some View {
        WebView(html: html)
    }
}

/// WebKit wrapper for rendering HTML
#if canImport(AppKit)
struct WebView: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
#else
struct WebView: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
#endif

#Preview {
    MarkdownPreviewView(html: """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                padding: 20px;
            }
            h1 { color: #333; }
        </style>
    </head>
    <body>
        <h1>Preview</h1>
        <p>This is a <strong>sample</strong> preview.</p>
    </body>
    </html>
    """)
}
