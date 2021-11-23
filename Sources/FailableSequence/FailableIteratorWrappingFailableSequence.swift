

public struct FailableIteratorWrappingFailableSequence<Base, Iterator>: FailableSequence
where Base: FailableSequence, Iterator: FailableIterator
{
    public typealias Element = Iterator.Element

    let base: Base
    let transformiterator: (Base.Iterator) -> Iterator
    public init(wrapping base: Base, transformIterator: @escaping (Base.Iterator) -> Iterator) {
        self.base = base
        self.transformiterator = transformIterator
    }

    public func makeIterator() -> Iterator {
        transformiterator(base.makeIterator())
    }
}
