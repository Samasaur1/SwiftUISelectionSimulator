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
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    static let gameScene: GameScene = GameScene()

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
