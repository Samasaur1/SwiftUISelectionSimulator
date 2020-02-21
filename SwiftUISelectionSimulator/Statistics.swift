struct Statistics {
    var generation: Int = 1
    var miscarriages: Int = 0
    var geneStats: [KeyPath<Organism, Double>: (min: Double, average: Double, max: Double)]

    init() {
        geneStats = [
            \Organism.genes.effectiveGenes.size: (0, 0, 0),
            \Organism.genes.effectiveGenes.sides: (0, 0, 0),
            \Organism.genes.effectiveGenes.hue: (0, 0, 0),
        ]
    }
}
