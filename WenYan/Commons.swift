//
//  Commons.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/20.
//

import Foundation
import WebKit
import UniformTypeIdentifiers
import SwiftUI

struct WebkitStatus {
    static let loadHandler = "loadHandler"
    static let contentChangeHandler = "contentChangeHandler"
    static let scrollHandler = "scrollHandler"
    static let clickHandler = "clickHandler"
}

// Helper to convert Swift string to JavaScript string literal
extension String {
    func toJavaScriptString() -> String {
        let escapedString = self
            .replacingOccurrences(of: "\\", with: "\\\\")  // 转义反斜杠
            .replacingOccurrences(of: "\"", with: "\\\"")  // 转义引号
            .replacingOccurrences(of: "\n", with: "\\n")   // 转义换行符
            .replacingOccurrences(of: "\r", with: "\\r")   // 转义回车符
            .replacingOccurrences(of: "\t", with: "\\t")   // 转义制表符
        
        // 添加前后引号，形成合法的 JavaScript 字符串字面量
        return "\"\(escapedString)\""
    }
}

func getResourceBundle() -> URL? {
    return Bundle.main.url(forResource: "Resources", withExtension: "bundle")
}

func loadFile(_ path: String) throws -> String {
    return try String(contentsOfFile: path, encoding: .utf8)
}

func loadFileFromResource(path: String) throws -> String {
    let nsPath = path as NSString
    let path = nsPath.deletingPathExtension
    let `extension` = nsPath.pathExtension
    return try loadFileFromResource(forResource: path, withExtension: `extension`)
}

func loadFileFromResource(forResource: String, withExtension: String) throws -> String {
    guard
        let resourceBundleURL = getResourceBundle(),
        let resourceBundle = Bundle(url: resourceBundleURL),
        let filePath = resourceBundle.path(forResource: forResource, ofType: withExtension)
    else {
        throw AppError.bizError(description: "Required resource is missing")
    }
    return try loadFile(filePath)
}

typealias JavascriptCallback = (Result<Any?, Error>) -> Void

func callJavascript(webView: WKWebView?, javascriptString: String, callback: JavascriptCallback? = nil) {
    webView?.evaluateJavaScript(javascriptString) { (response, error) in
        if let error = error {
            callback?(.failure(error))
        }
        else {
            callback?(.success(response))
        }
    }
}

enum ThemeStyle: String {
    case gzhDefault = "themes/gzh_default.css"
    case toutiaoDefault = "themes/toutiao_default.css"
    case zhihuDefault = "themes/zhihu_default.css"
    case juejinDefault = "themes/juejin_default.css"
    case mediumDefault = "themes/medium_default.css"
    case orangeHeart = "themes/orangeheart.css"
    case rainbow = "themes/rainbow.css"
    case lapis = "themes/lapis.css"
    case pie = "themes/pie.css"
    case maize = "themes/maize.css"
    case purple = "themes/purple.css"
    
    var name: String {
        switch self {
        case .gzhDefault: "默认"
        case .toutiaoDefault: "默认"
        case .zhihuDefault: "默认"
        case .juejinDefault: "默认"
        case .mediumDefault: "默认"
        case .orangeHeart: "Orange Heart"
        case .rainbow: "Rainbow"
        case .lapis: "Lapis"
        case .pie: "Pie"
        case .maize: "Maize"
        case .purple: "Purple"
        }
    }
    
    var author: String {
        switch self {
        case .gzhDefault: ""
        case .toutiaoDefault: ""
        case .zhihuDefault: ""
        case .juejinDefault: ""
        case .mediumDefault: ""
        case .orangeHeart: "evgo2017"
        case .rainbow: "thezbm"
        case .lapis: "YiNN"
        case .pie: "kevinzhao2233"
        case .maize: "BEATREE"
        case .purple: "hliu202"
        }
    }
}

enum HighlightStyle: String {
    case idea = "highlight/styles/idea.min.css"
    case monokai = "highlight/styles/monokai.min.css"
    case github = "highlight/styles/github.min.css"
}

enum PreviewMode: String {
    case mobile = "style.css"
    case desktop = "desktop_style.css"
}

enum Platform: String, CaseIterable, Identifiable {
    case gzh
    case toutiao
    case zhihu
    case juejin
    case medium
    
    var id: Self { self }
    
    var themes: [ThemeStyle] {
        switch self {
        case .gzh:
            return [.gzhDefault, .orangeHeart, .rainbow, .lapis, .pie, .maize, .purple]
        case .zhihu:
            return [.zhihuDefault]
        case .toutiao:
            return [.toutiaoDefault]
        case .juejin:
            return [.juejinDefault]
        case .medium:
            return [.mediumDefault]
        }
    }
}

struct DataFile: FileDocument {
    static var readableContentTypes: [UTType] { [.jpeg] }
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

enum ThemeType {
    case builtin
    case custom
}

struct ThemeStyleWrapper: Equatable, Hashable {
    let themeType: ThemeType
    let themeStyle: ThemeStyle?
    let customTheme: CustomTheme?
    
    init(themeType: ThemeType, themeStyle: ThemeStyle? = nil, customTheme: CustomTheme? = nil) {
        self.themeType = themeType
        self.themeStyle = themeStyle
        self.customTheme = customTheme
    }
    
    static func == (lhs: ThemeStyleWrapper, rhs: ThemeStyleWrapper) -> Bool {
        if lhs.themeType == .builtin {
            return rhs.themeType == .builtin && lhs.themeStyle == rhs.themeStyle
        }
        if lhs.themeType == .custom {
            return rhs.themeType == .custom && lhs.customTheme == rhs.customTheme
        }
        return false
    }
    
    func name() -> String {
        switch themeType {
        case .builtin:
            return themeStyle!.name
        case .custom:
            return customTheme!.name ?? ""
        }
    }
    
    func author() -> String {
        switch themeType {
        case .builtin:
            return themeStyle!.author
        case .custom:
            return ""
        }
    }
    
    func id() -> String {
        switch themeType {
        case .builtin:
            return themeStyle!.rawValue
        case .custom:
            return "custom/\(customTheme!.objectID.uriRepresentation().absoluteString)"
        }
    }
}

func getAppinfo(for key: String) -> String? {
    return Bundle.main.infoDictionary?[key] as? String
}
