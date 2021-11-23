

public extension FailableSequence {
    func forEach(_ body: (Element) throws -> Void) throws {
        var iterator = makeIterator()
        while let element = try iterator.next() {
            try body(element)
        }
    }
}

public extension FailableSequence {
    var forceNoThrowSequence: UnfoldSequence<Element, Iterator> {
        var iterator = makeIterator()
        return sequence(state: makeIterator()) { state in
            try! iterator.next()
        }
    }
}

public extension FailableSequence {
    var skipOnThrowSequence: UnfoldSequence<Element, Iterator> {
        var iterator = makeIterator()
        return sequence(state: makeIterator()) { state in
            while true {
                do { return try iterator.next() }
                catch { continue }
            }
        }
    }
}

public struct DropFirstFailableIterator<Base>: FailableIterator
where Base: FailableIterator
{
    public typealias Element = Base.Element

    var base: Base
    var count: Int

    public mutating func next() throws -> Element? {
        while count > 0 {
            guard try base.next() != nil else { return nil }
            count -= 1
        }
        guard let element = try base.next() else { return nil }
        return element
    }
}

public extension FailableSequence {
    func dropFirst(_ k: Int = 1) -> FailableIteratorWrappingFailableSequence<Self, DropFirstFailableIterator<Self.Iterator>> {
        FailableIteratorWrappingFailableSequence(wrapping: self) { iterator in
            DropFirstFailableIterator(base: iterator, count: k)
        }
    }
}

public struct MappedFailableIterator<Base, Element>: FailableIterator
where Base: FailableIterator
{
    var base: Base
    let transform: (Base.Element) throws -> Element

    public mutating func next() throws -> Element? {
        guard let element = try base.next() else { return nil }
        return try transform(element)
    }
}

public extension FailableSequence {
    func map<ElementOfResult>(_ transform: @escaping (Element) throws -> ElementOfResult) -> FailableIteratorWrappingFailableSequence<Self, MappedFailableIterator<Self.Iterator, ElementOfResult>> {
        FailableIteratorWrappingFailableSequence(wrapping: self) { iterator in
            MappedFailableIterator(base: iterator, transform: transform)
        }
    }
}

public struct CompactMappedFailableIterator<Base, Element>: FailableIterator
where Base: FailableIterator
{
    var base: Base
    let transform: (Base.Element) throws -> Element?

    public mutating func next() throws -> Element? {
        while true {
            guard let element = try base.next() else { return nil }
            guard let result = try transform(element) else { continue }
            return result
        }
    }
}

public extension FailableSequence {
    func compactMap<ElementOfResult>(_ transform: @escaping (Self.Element) throws -> ElementOfResult?) -> FailableIteratorWrappingFailableSequence<Self, CompactMappedFailableIterator<Self.Iterator, ElementOfResult>> {
        FailableIteratorWrappingFailableSequence(wrapping: self) { iterator in
            CompactMappedFailableIterator(base: iterator, transform: transform)
        }
    }
}

public struct FilteredFailableIterator<Base>: FailableIterator
where Base: FailableIterator
{
    var base: Base
    let isIncluded: (Base.Element) throws -> Bool

    public mutating func next() throws -> Base.Element? {
        while true {
            guard let element = try base.next() else { return nil }
            guard try isIncluded(element) else { continue }
            return element
        }
    }
}

public extension FailableSequence {
    func filter(_ isIncluded: @escaping (Element) throws -> Bool) rethrows -> FailableIteratorWrappingFailableSequence<Self, FilteredFailableIterator<Self.Iterator>> {
        FailableIteratorWrappingFailableSequence(wrapping: self) { iterator in
            FilteredFailableIterator(base: iterator, isIncluded: isIncluded)
        }
    }
}
