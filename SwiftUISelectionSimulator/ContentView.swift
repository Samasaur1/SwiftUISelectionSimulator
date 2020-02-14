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
    let comparisonKeyPaths = [\GeneValues.sides, \GeneValues.hue, \GeneValues.size]
    let lookupTable = [\GeneValues.sides: "Number of Sides", \GeneValues.hue: "Hue", \GeneValues.size: "Size"]
    @State var selection = \GeneValues.sides
    var body: some View {
        return SceneView(scene: GameScene())
        return VStack {
            HStack {
                Picker("Primary Selection Type", selection: $selection) {
                    ForEach(comparisonKeyPaths, id: \.self) { kp in
                        Text(self.lookupTable[kp]!)
                    }
                }
            }
            SceneView(scene: AppDelegate.gameScene.settingComparisonType(to: selection))
        }
    }
}
struct SceneView: NSViewRepresentable {
    let scene: SKScene

//    init(scene: SKScene) {
//        self.scene = scene
//    }

    init(scene: GameScene) {
        self.scene = scene
        scene.size = .init(width: 1024, height: 768)
        scene.anchorPoint = .init(x: 0.5, y: 0.5)
        scene.scaleMode = .aspectFill
    }

    func makeNSView(context: NSViewRepresentableContext<SceneView>) -> SKView {
        let view = SKView(frame: .zero)
        view.showsNodeCount = true
        view.showsFPS = true
        view.presentScene(scene)
        return view
    }

    func updateNSView(_ nsView: SKView, context: NSViewRepresentableContext<SceneView>) {}
}
