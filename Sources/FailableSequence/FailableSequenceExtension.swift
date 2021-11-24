
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

public struct DropFirstFailableSequence<Base>: FailableSequence, FailableIterator
where Base: FailableSequence
{
    public typealias Element = Base.Element

    private var base: Base
    private var count: Int
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, count: Int) {
        self.base = base
        self.count = count
    }

    public mutating func next() throws -> Element? {
        while count > 0 {
            guard try iterator.next() != nil else { return nil }
            count -= 1
        }

        return try iterator.next()
    }
}

public extension FailableSequence {
    func dropFirst(_ k: Int = 1) -> DropFirstFailableSequence<Self> {
        DropFirstFailableSequence(self, count: k)
    }
}

public struct MappedFailableSequence<Base, Element>: FailableSequence, FailableIterator
where Base: FailableSequence
{
    private var base: Base
    private let transform: (Base.Element) throws -> Element
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, transform: @escaping (Base.Element) throws -> Element) {
        self.base = base
        self.transform = transform
    }

    public mutating func next() throws -> Element? {
        guard let element = try iterator.next() else { return nil }
        return try transform(element)
    }
}

public extension FailableSequence {
    func map<ElementOfResult>(_ transform: @escaping (Element) throws -> ElementOfResult) -> MappedFailableSequence<Self, ElementOfResult> {
        MappedFailableSequence(self, transform: transform)
    }
}

public struct CompactMappedFailableSequence<Base, Element>: FailableSequence, FailableIterator
where Base: FailableSequence
{
    private var base: Base
    private let transform: (Base.Element) throws -> Element?
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, transform: @escaping (Base.Element) throws -> Element?) {
        self.base = base
        self.transform = transform
    }

    public mutating func next() throws -> Element? {
        while true {
            guard let element = try iterator.next() else { return nil }
            guard let result = try transform(element) else { continue }
            return result
        }
    }
}

public extension FailableSequence {
    func compactMap<ElementOfResult>(_ transform: @escaping (Self.Element) throws -> ElementOfResult?) -> CompactMappedFailableSequence<Self, ElementOfResult> {
        CompactMappedFailableSequence(self, transform: transform)
    }
}

public struct FilteredFailableSequence<Base>: FailableSequence, FailableIterator
where Base: FailableSequence
{
    public typealias Element = Base.Element

    private var base: Base
    private let isIncluded: (Base.Element) throws -> Bool
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, isIncluded: @escaping (Base.Element) throws -> Bool) {
        self.base = base
        self.isIncluded = isIncluded
    }

    public mutating func next() throws -> Element? {
        while true {
            guard let element = try iterator.next() else { return nil }
            guard try isIncluded(element) else { continue }
            return element
        }
    }
}

public extension FailableSequence {
    func filter(_ isIncluded: @escaping (Element) throws -> Bool) rethrows -> FilteredFailableSequence<Self> {
        FilteredFailableSequence(self, isIncluded: isIncluded)
    }
}

public struct PrefixFailableSequence<Base>: FailableSequence, FailableIterator where Base: FailableSequence {
    public typealias Element = Base.Element

    private var base: Base
    private var maxLength: Int
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, maxLength: Int) {
        self.base = base
        self.maxLength = maxLength
    }

    public mutating func next() throws -> Element? {
        if maxLength == 0 { return nil }
        maxLength -= 1
        return try iterator.next()
    }
}

public extension FailableSequence {
    func prefix(_ maxLength: Int) -> PrefixFailableSequence<Self> {
        PrefixFailableSequence(self, maxLength: maxLength)
    }
}
