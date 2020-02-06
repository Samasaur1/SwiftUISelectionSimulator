//
//  Organism.swift
//  SelectionSimulator
//
//  Created by Sam Gauck on 10/29/19.
//  Copyright © 2019 Sam Gauck. All rights reserved.
//

import Foundation
import SpriteKit

class Organism {
    private(set) var node: SKNode
    private(set) var genes: GeneSetPair
    private weak var scene: SKScene?

    public init(with genes: GeneSetPair, in scene: SKScene? = nil) {
        self.genes = genes
        self.node = genes.effectiveGenes.generateNode()
        self.scene = scene
        scene?.addChild(self.node)
    }

//    func mutate() {
////        self.values.mutate()
//        self.node.removeFromParent()
//        self.node = genes.effectiveGenes.generateNode()
//        self.scene?.addChild(self.node)
//    }

    static func from(parents p1: Organism, and p2: Organism) -> Organism {
        return Organism(with: GeneSetPair.from(p1.genes, and: p2.genes), in: p1.scene ?? p2.scene)
    }

    var position: CGPoint {
        get {
            return self.node.position
        }
        set {
            self.node.position = newValue
        }
    }

    func move(to point: CGPoint, duration: TimeInterval = 1) {
        self.node.run(.move(to: point, duration: duration))
    }

    func die(duration: TimeInterval = 1) {
        let u = UUID()
        Organism.DYING[u] = self
        self.node.run(.sequence([.fadeOut(withDuration: duration), .run {
            Organism.DYING[u] = nil
            }]))
    }

    private static var DYING: [UUID: Organism] = [:]

    deinit {
        self.node.removeFromParent()
    }
}

struct GeneSet {
    let size: Gene
    let sides: Gene
    let hue: Gene

//    init(size: Gene, sides: Gene) { //memberwise init
//        self.size = size
//        self.sides = sides
//    }

    func mutated() -> GeneSet {
        var arr = array
        let i = Int.random(in: 0..<arr.count)
        arr[i].mutate()
        return GeneSet(size: arr[0], sides: arr[1], hue: arr[2])
    }

    mutating func mutate() {
        self = self.mutated()
    }

    var array: [Gene] {
        return [size, sides, hue]
    }
}

struct GeneSetPair {
    let set1: GeneSet
    let set2: GeneSet

    func genesToPassOn() -> GeneSet {
        let set1arr = set1.array
        let set2arr = set2.array
        var arr: [Gene] = []
        for (val1, val2) in zip(set1arr, set2arr) {
            arr.append(Bool.random() ? val1 : val2)
        }
        return GeneSet(size: arr[0], sides: arr[1], hue: arr[2])
    }

    var effectiveGenes: GeneValues {
        let size: Double
        let sides: Double
        let hue: Double

        switch (set1.size, set2.size) {
        case let (.number(value), .number(value2)):
            size = max(value, value2)
        case (.number(let value), .multiplier(let mul)), (.multiplier(let mul), .number(let value)):
            size = value * mul
        case (.multiplier, .multiplier):
            size = 3
        }

        switch (set1.sides, set2.sides) {
        case let (.number(value), .number(value2)):
            sides = max(value, value2)
        case (.number(let value), .multiplier(let mul)), (.multiplier(let mul), .number(let value)):
            sides = value * mul
        case (.multiplier, .multiplier):
            sides = 1
        }

        switch (set1.hue, set2.hue) {
        case let (.number(value), .number(value2)):
            hue = max(value, value2)
        case (.number(let value), .multiplier(let mul)), (.multiplier(let mul), .number(let value)):
            hue = value * mul
        case (.multiplier, .multiplier):
            hue = 1
        }

        return GeneValues(size: size, sides: sides, hue: hue)
    }

    static func from(_ set1: GeneSetPair, and set2: GeneSetPair) -> GeneSetPair {
        return withAProbabilityOf(0.5, return: {
            var new1 = set1.genesToPassOn()
            var new2 = set2.genesToPassOn()
            if Bool.random() {
                new1.mutate()
            } else {
                new2.mutate()
            }
            return GeneSetPair(set1: new1, set2: new2)
        }, else: {
            return GeneSetPair(set1: set1.genesToPassOn(), set2: set2.genesToPassOn())
        })
    }

    static func `default`() -> GeneSetPair {
        return GeneSetPair(set1: GeneSet(size: .number(10), sides: .number(6), hue: .number(10)), set2: GeneSet(size: .number(10), sides: .number(6), hue: .number(10)))
    }
}

struct GeneValues {
    let size: Double
    let sides: Double
    let hue: Double

//    init(size: Double, sides: Double) { //memberwise init
//        self.size = size
//        self.sides = sides
//    }

    func generateNode() -> SKNode {
        let node = nGon(sides: Int(sides), sideLength: size)
        node.fillColor = NSColor(calibratedHue: CGFloat(hue/20), saturation: 1, brightness: 1, alpha: 1)
        return node
    }
}

enum Gene {
    private static let NUMBER_VARIANCE: Double = 1
    private static let MULTIPLIER_VARIANCE: Double = 0.25
    private static let DEFAULT_MULTIPLER: Double = 1
    private static let DEFAULT_NUMBER: Double = 8

    case number(Double)
    case multiplier(Double)

    func mutated() -> Gene {
        switch self {
        case let .number(value):
            return withAProbabilityOf(0.1, return: {
                return Gene.multiplier(value / Gene.DEFAULT_NUMBER)
            }, else: {
                return Gene.number(value + (Bool.random() ? Gene.NUMBER_VARIANCE : -Gene.NUMBER_VARIANCE))
            })
        case let .multiplier(mul):
            return withAProbabilityOf(0.1, return: {
                return Gene.number(mul * Gene.DEFAULT_NUMBER)
            }, else: {
                return Gene.multiplier(mul + (Bool.random() ? Gene.MULTIPLIER_VARIANCE : -Gene.MULTIPLIER_VARIANCE))
            })
        }
    }

    mutating func mutate() {
        self = self.mutated()
    }
}


public func withAProbabilityOf(_ probability: Double, do ifTrue: () -> Void, else ifFalse: () -> Void) {
    if Double.random(in: 0...1) <= probability {
        ifTrue()
    } else {
        ifFalse()
    }
}

public func withAProbabilityOf<ReturnType>(_ probability: Double, return ifTrue: () -> ReturnType, else ifFalse: () -> ReturnType) -> ReturnType {
    if Double.random(in: 0...1) <= probability {
        return ifTrue()
    } else {
        return ifFalse()
    }
}

public func nGon(sides n: Int, sideLength l: Double) -> SKShapeNode {
    let alpha = Double.pi * 2 / Double(n)

    var points: [CGPoint] = [CGPoint.zero]
    for i in 1..<n {
        let x = points[i-1].x + CGFloat(l * cos(Double(i - 1) * alpha))
        let y = points[i-1].y + CGFloat(l * sin(Double(i - 1) * alpha))
        points.append(CGPoint(x: x, y: y))
    }
    points.append(CGPoint.zero)

//    return SKShapeNode(points: &points, count: points.count) //-> (0, 0) is the first vertex

    let hShift: CGFloat = -CGFloat(l/2)
    let vShift: CGFloat = -points[Int(ceil(Double(n)/2))].y / 2
    for i in 0..<points.count {
        points[i].x += hShift
        points[i].y += vShift
    }

    return SKShapeNode(points: &points, count: points.count)
}
