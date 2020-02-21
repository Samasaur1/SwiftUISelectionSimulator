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
import Combine


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
                VStack {
                    Text("Active Gene for Selection")
                    Picker("Active Gene for Selection", selection: $geneKeyPathSelection) {
                        ForEach(geneKeyPaths, id: \.self) { kp in
                            Text(self.geneKeyPathLabelLookupTable[kp]!)
                        }
                    }.labelsHidden().pickerStyle(PopUpButtonPickerStyle())
                }.padding(5).background(Color.white.opacity(0.25)).cornerRadius(10)
                VStack {
                    Text("Selection Type")
                    Picker("Selection Type", selection: $selectionType) {
                        ForEach(selectionTypes, id: \.self) { comp in
                            Text(comp)
                        }
                    }.labelsHidden().pickerStyle(PopUpButtonPickerStyle())
                }.padding(5).background(Color.white.opacity(0.25)).cornerRadius(10)
                VStack {
                    Picker("Speed", selection: $speed) {
                        Text("􀊃 (0.5x)").tag(0.5)
                        Text("􀊄 (1x)").tag(1.0)
                        Text("􀊌 (2x)").tag(2.0)
                        Text("􀊌 (4x)").tag(4.0)
                        Text("􀊌 (8x)").tag(8.0)
                    }.labelsHidden().pickerStyle(SegmentedPickerStyle())
                }.padding(5).background(Color.white.opacity(0.25)).cornerRadius(10)
                Button(action: {
                    AppDelegate.shared.reset()
                }) {
                    Text("Restart Simulation")
                }
            }.padding(5).background(Color.gray).cornerRadius(10)
            HStack {
                VStack {
                    Text("Statistics").underline().bold().font(.largeTitle)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Generation:").bold()
                            Text(String(statistics.generation))
                        }
                        HStack {
                            Text("Miscarriages:").bold()
                            Text(String(statistics.miscarriages))
                        }
                        ForEach(geneKeyPaths, id: \.self) { kp in
                            VStack(alignment: .leading) {
                                Text(self.geneKeyPathLabelLookupTable[kp]! + ":").bold()
                                HStack {
                                    Text("  Lowest:")
                                    Text(String(format: "%.3f", locale: Locale.current, self.statistics.geneStats[kp]!.min))
                                }
                                HStack {
                                    Text("  Average:")
                                    Text(String(format: "%.3f", locale: Locale.current,
                                                self.statistics.geneStats[kp]!.average))
                                }
                                HStack {
                                    Text("  Highest:")
                                    Text(String(format: "%.3f", locale: Locale.current,
                                                self.statistics.geneStats[kp]!.max))
                                }
                            }
                        }
                    }
                }
                SceneView(scene: AppDelegate.shared.gameScene
                    .settingGene(to: geneKeyPathSelection)
                    .settingSelectionType(to: selectionTypeFunctionLookupTable[selectionType]!)
                    .settingSpeed(to: speed))
                    .frame(width: 1024, height: 700, alignment: .center)
            }
        }.frame(width: 1250, height: 800, alignment: .center)
            .onReceive(AppDelegate.shared.gameScene.$stats) { self.statistics = $0 }
    }

    @State var statistics = Statistics()
}
struct SceneView: NSViewRepresentable {
    let scene: SKScene

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
