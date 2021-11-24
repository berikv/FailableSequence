
public struct IteratorWrappingFailableIterator<Base>: FailableIterator where Base: IteratorProtocol {
    public typealias Element = Base.Element

    private var _base: Base

    public init(_ base: Base) {
        self._base = base
    }

    public mutating func next() throws -> Base.Element? {
        _base.next()
    }
}

public struct SequenceWrappingFailableSequence<Base>: FailableSequence where Base: Sequence {
    public typealias Element = Base.Element
    public typealias Iterator = IteratorWrappingFailableIterator<Base.Iterator>

    private let _base: Base

    public init(_ base: Base) {
        self._base = base
    }

    public func makeIterator() -> IteratorWrappingFailableIterator<Base.Iterator> {
        return IteratorWrappingFailableIterator(_base.makeIterator())
    }
}

public extension Sequence {
    var failable: SequenceWrappingFailableSequence<Self> {
        SequenceWrappingFailableSequence(self)
    }
}

public extension IteratorProtocol {
    var failable: IteratorWrappingFailableIterator<Self> {
        IteratorWrappingFailableIterator(self)
    }
}

// Resolve ambiguoush initializer issue
public extension Sequence where Self == Self.Iterator {
    var failable: IteratorWrappingFailableIterator<Self> {
        IteratorWrappingFailableIterator(self)
    }
}

public extension Sequence {
    func failableMap<ElementOfResult>(_ transform: @escaping (Element) throws -> ElementOfResult) -> MappedFailableSequence<SequenceWrappingFailableSequence<Self>, ElementOfResult> {
        failable.map(transform)
    }
}

