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

    let comparisons = ["Ascending", "Descending"]
    let comparisonLookupTable: [String: (Double, Double) -> Bool] = ["Ascending": (<), "Descending": (>)]
    @State var comparison = "Descending"

    @State var speed: Double = 1

    var body: some View {
        return VStack {
            HStack {
                Picker("Primary Selection Type", selection: $selection) {
                    ForEach(comparisonKeyPaths, id: \.self) { kp in
                        Text(self.lookupTable[kp]!)
                    }
                }
                Picker("Mode", selection: $comparison) {
                    ForEach(comparisons, id: \.self) { comp in
                        Text(comp)
                    }
                }.pickerStyle(RadioGroupPickerStyle())
                Picker("", selection: $speed) {
                    Text("􀊃 (0.5x)").tag(0.5)
                    Text("􀊄 (1x)").tag(1.0)
                    Text("􀊌 (2x)").tag(2.0)
                    Text("􀊌 (4x)").tag(4.0)
                    Text("􀊌 (8x)").tag(8.0)
                }.pickerStyle(SegmentedPickerStyle())
            }
            SceneView(scene: AppDelegate.gameScene.settingComparisonType(to: selection, inMode: comparisonLookupTable[comparison]!).settingSpeed(to: speed))
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
