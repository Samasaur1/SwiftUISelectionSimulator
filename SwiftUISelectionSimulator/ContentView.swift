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
    let geneKeyPaths = [\Organism.genes.effectiveGenes.sides, \Organism.genes.effectiveGenes.hue, \Organism.genes.effectiveGenes.size]
    let geneKeyPathLabelLookupTable = [\Organism.genes.effectiveGenes.sides: "Number of Sides", \Organism.genes.effectiveGenes.hue: "Hue", \Organism.genes.effectiveGenes.size: "Size"]
    @State var geneKeyPathSelection = \Organism.genes.effectiveGenes.sides

    let selectionTypes = ["Directional (Ascending)", "Directional (Descending)", "Disruptive", "Stabilizing"]
    let selectionTypeFunctionLookupTable: [String: (inout [Organism], KeyPath<Organism, Double>) -> Void] = [
        "Directional (Ascending)": { arr, kp in
            arr.sort { $0[keyPath: kp] < $1[keyPath: kp] }
        },
        "Directional (Descending)": { arr, kp in
            arr.sort { $0[keyPath: kp] > $1[keyPath: kp] }
        },
        "Disruptive": { arr, kp in
            let average = arr.average { $0[keyPath: kp] }
            arr.sort { abs($0[keyPath: kp] - average) > abs($1[keyPath: kp] - average) }
        },
        "Stabilizing": { arr, kp in
            let average = arr.average { $0[keyPath: kp] }
            arr.sort { abs($0[keyPath: kp] - average) < abs($1[keyPath: kp] - average) }
        }
    ]
    @State var selectionType = "Directional (Descending)"

    @State var speed: Double = 1

    var body: some View {
        return VStack {
            HStack {
                Picker("Primary Selection Type", selection: $geneKeyPathSelection) {
                    ForEach(geneKeyPaths, id: \.self) { kp in
                        Text(self.geneKeyPathLabelLookupTable[kp]!)
                    }
                }
                Picker("Mode", selection: $selectionType) {
                    ForEach(selectionTypes, id: \.self) { comp in
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
                Button(action: {
                    AppDelegate.shared.reset()
                }) {
                    Text("Restart Simulation")
                }
            }
            SceneView(scene: AppDelegate.shared.gameScene
                .settingGene(to: geneKeyPathSelection)
                .settingSelectionType(to: selectionTypeFunctionLookupTable[selectionType]!)
                .settingSpeed(to: speed))
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
