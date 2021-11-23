
public struct SequenceWrappingFailableIterator<Base>: FailableIterator where Base: IteratorProtocol {
    public typealias Element = Base.Element

    var _base: Base
    public init(_ base: Base) {
        self._base = base
    }

    public mutating func next() throws -> Base.Element? {
        _base.next()
    }
}

public struct SequenceWrappingFailableSequence<Base>: FailableSequence where Base: Sequence {
    public typealias Element = Base.Element
    public typealias Iterator = SequenceWrappingFailableIterator<Base.Iterator>

    let _base: Base
    public init(_ base: Base) {
        self._base = base
    }

    public func makeIterator() -> SequenceWrappingFailableIterator<Base.Iterator> {
        return SequenceWrappingFailableIterator(_base.makeIterator())
    }
}

public extension Sequence {
    func failableMap<ElementOfResult>(_ transform: @escaping (Element) throws -> ElementOfResult) -> FailableIteratorWrappingFailableSequence<SequenceWrappingFailableSequence<Self>, MappedFailableIterator<SequenceWrappingFailableIterator<Self.Iterator>, ElementOfResult>> {
        SequenceWrappingFailableSequence(self).map(transform)
    }
}
