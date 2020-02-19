public extension Array {
    func sum<T: SignedNumeric>(by transform: (Element) -> T) -> T {
        return self.reduce(into: 0) { res, el in
            res += transform(el)
        }
    }

    func average(by transform: (Element) -> Double) -> Double {
        return self.sum(by: transform)/Double(self.count)
    }
}
