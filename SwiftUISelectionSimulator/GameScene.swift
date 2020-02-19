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
    var comparator: (Double, Double) -> Bool = (>)

    var speedMultiplier: Double = 1

    func settingComparisonType(to ct: KeyPath<GeneValues, Double>, inMode m: @escaping (Double, Double) -> Bool) -> GameScene {
        comparisonType = ct
        comparator = m
        print("setting ct to \(ct) in mode \(m(1, 2) ? "A" : "D") on \(Unmanaged.passUnretained(self).toOpaque())")
        return self
    }

    func settingSpeed(to s: Double) -> GameScene {
        speedMultiplier = s
        print("setting speed to \(s)x")
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

        for (o, p) in zip(organisms, points) {
            o.position = p
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > lastMovementTime + (5/speedMultiplier) {
            lastMovementTime = currentTime
            lastDeathTime = currentTime
            lastReproductionTime = currentTime

            for (o, p) in zip(organisms, points) {
                o.move(to: p, duration: 1/speedMultiplier)
            }
        } else if currentTime > lastDeathTime + (3/speedMultiplier) {
            lastDeathTime = currentTime
            lastReproductionTime = currentTime

            organisms.shuffle()
            organisms.sort { comparator($0.genes.effectiveGenes[keyPath: comparisonType], $1.genes.effectiveGenes[keyPath: comparisonType]) }
            print("[\(Unmanaged.passUnretained(self).toOpaque())] \(comparisonType) (\(comparator(1, 2) ? "A" : "D")) (\(speedMultiplier)x)")
            while organisms.count > points.count {
                organisms.removeLast().die(duration: 1/speedMultiplier)
            }
        } else if currentTime > lastReproductionTime + (2/speedMultiplier) {
            lastReproductionTime = currentTime
            for i in stride(from: 0, to: organisms.count - 1, by: 2) {
                if let o = try? Organism.from(parents: organisms[i], and: organisms[i + 1]) {
                    o.position = organisms[i].position
                    o.position.x += 50
                    o.position.y -= 25
                    organisms.append(o)
                } else {
                    print("Organisms tried to have a child, but failed!")
                }
            }
        }
    }
}
