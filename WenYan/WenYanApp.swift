//
//  WenYanApp.swift
//  WenYan
//
//  Created by Lei Cao on 2024/8/19.
//

import SwiftUI

@main
struct WenYanApp: App {
    
    @StateObject private var appState: AppState
    @StateObject private var markdownViewModel: MarkdownViewModel
    @StateObject private var htmlViewModel: HtmlViewModel
    @StateObject private var cssEditorViewModel: CssEditorViewModel
    @StateObject private var themePreviewViewModel: ThemePreviewViewModel
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _markdownViewModel = StateObject(wrappedValue: MarkdownViewModel(appState: appState))
        _htmlViewModel = StateObject(wrappedValue: HtmlViewModel(appState: appState))
        _cssEditorViewModel = StateObject(wrappedValue: CssEditorViewModel(appState: appState))
        _themePreviewViewModel = StateObject(wrappedValue: ThemePreviewViewModel(appState: appState))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(markdownViewModel)
                .environmentObject(htmlViewModel)
                .environmentObject(cssEditorViewModel)
                .environmentObject(themePreviewViewModel)
                .alert(isPresented: appState.showError, error: appState.appError) {}
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("关于文颜") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.version: ""
                        ]
                    )
                }
            }
            CommandGroup(replacing: .help) {
                if let helpURL = getAppinfo(for: "HelpUrl"), let url = URL(string: helpURL) {
                    Link("文颜帮助", destination: url)
                }
            }
//            CommandGroup(after: .textEditing) {
//                Button("HTML转换") {
//                }
//            }
        }
    }

}
