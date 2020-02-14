//
//  GameScene.swift
//  SelectionSimulator
//
//  Created by Sam Gauck on 10/29/19.
//  Copyright © 2019 Sam Gauck. All rights reserved.
//

import SpriteKit
import GameplayKit

typealias Family = (parent: Organism, parent2: Organism, child: Organism)

class GameScene: SKScene {
    var lastMovementTime: TimeInterval = 0
    var lastDeathTime: TimeInterval = 0
    var lastReproductionTime: TimeInterval = 0
    var points: [CGPoint] = []
    var organisms: [Organism] = []

    var comparisonType: KeyPath<GeneValues, Double> = \.sides

    func settingComparisonType(to ct: KeyPath<GeneValues, Double>) -> GameScene {
        comparisonType = ct
        print("setting ct to \(ct) on \(Unmanaged.passUnretained(self).toOpaque())")
        return self
    }

    override func didMove(to view: SKView) {
        let r = self.frame.width/2
        let vR = self.frame.height/2

        for x in stride(from: -r + 100, through: r, by: 100) { //150
            for y in stride(from: -vR + 100, through: vR, by: 100) { //150
                points.append(CGPoint(x: x - 50, y: y - 50)) //75
            }
        }

        points.sort { first, second in
            if first.y > second.y {
                return true
            } else if first.y < second.y {
                return false
            } else {
                return first.x < second.x
            }
        }


        for _ in 0..<2 {
            organisms.append(Organism(with: GeneSetPair.default(), in: self))
        }
//        organisms.append(Organism(with: GeneSetPair(set1: GeneSet(size: .number(10), sides: .number(10), red: .multiplier(3), green: .number(10), blue: .number(40)), set2: GeneSet(size: .number(10), sides: .number(10), red: .multiplier(3), green: .number(10), blue: .multiplier(0.25))), in: self))

        for (o, p) in zip(organisms, points) {
            o.position = p
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > lastMovementTime + 5 {
            lastMovementTime = currentTime
            lastDeathTime = currentTime
            lastReproductionTime = currentTime

//            for (o, p) in zip(organisms, points) {
//                o.position = p
//            }
            for (o, p) in zip(organisms, points) {
                o.move(to: p)
            }
        } else if currentTime > lastDeathTime + 3 {
            lastDeathTime = currentTime
            lastReproductionTime = currentTime

            organisms.shuffle()
            organisms.sort { $0.genes.effectiveGenes.sides > $1.genes.effectiveGenes.sides }
            organisms.sort { $0.genes.effectiveGenes[keyPath: comparisonType] > $1.genes.effectiveGenes[keyPath: comparisonType] }
            print("[\(Unmanaged.passUnretained(self).toOpaque())] \(comparisonType)")
            while organisms.count > points.count {
                organisms.removeLast().die()
            }
        } else if currentTime > lastReproductionTime + 2 {
            lastReproductionTime = currentTime
            for i in stride(from: 0, to: organisms.count - 1, by: 2) {
                let o = Organism.from(parents: organisms[i], and: organisms[i + 1])
                o.position = organisms[i].position
                o.position.x += 50
                o.position.y -= 25
                organisms.append(o)
            }
        }
    }
}
