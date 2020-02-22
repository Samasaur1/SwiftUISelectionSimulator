//
//  AppDelegate.swift
//  SwiftUISelectionSimulator
//
//  Created by Sam Gauck on 2/6/20.
//  Copyright © 2020 Sam Gauck. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.shared = self

        gameScene = GameScene()
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.title = "Selection Simulator"
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private(set) var gameScene: GameScene = GameScene()

    static private(set) var shared: AppDelegate! = nil

    func reset() {
        if let w = window {
            gameScene = GameScene()
            w.contentView = NSHostingView(rootView: ContentView())
        }
    }
}

extension KeyPath: CustomStringConvertible {
    public var description: String {
        switch self {
        case \GeneValues.size: return "\\GeneValues.size"
        case \GeneValues.sides: return "\\GeneValues.sides"
        case \GeneValues.hue: return "\\GeneValues.hue"
        default: return "Swift.KeyPath<\(Root.self), \(Value.self)"
        }
    }
}
