//
//  ContentView.swift
//  SwiftUISelectionSimulator
//
//  Created by Sam Gauck on 2/6/20.
//  Copyright © 2020 Sam Gauck. All rights reserved.
//

import SwiftUI
import SpriteKit
import AppKit

struct ContentView: View {
    var body: some View {
        let scene = GameScene()
        scene.size = .init(width: 1024, height: 768)
        scene.anchorPoint = .init(x: 0.5, y: 0.5)
        scene.scaleMode = .aspectFill
        return SceneView(scene: scene)
    }
}
struct SceneView: NSViewRepresentable {
    let scene: SKScene

    func makeNSView(context: NSViewRepresentableContext<SceneView>) -> SKView {
        let view = SKView(frame: .zero)
        view.showsNodeCount = true
        view.showsFPS = true
        return view
    }

    func updateNSView(_ nsView: SKView, context: NSViewRepresentableContext<SceneView>) {
        nsView.presentScene(scene)
    }
}
