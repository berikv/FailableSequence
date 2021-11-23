
public struct AnyFailableIterator<Element>: FailableIterator {
    let _next: () throws -> Element?

    public init<FI>(_ base: FI) where Element == FI.Element, FI : FailableIterator {
        var base = base
        _next = { try base.next() }
    }

    public init(_ body: @escaping () throws -> Element?) {
        _next = body
    }

    public init() {
        _next = { nil }
    }

    public mutating func next() throws -> Element? {
        try _next()
    }
}

extension AnyFailableIterator: FailableSequence {
     public func makeIterator() -> AnyFailableIterator<Element> {
         self
    }
}

public struct AnyFailableSequence<Element>: FailableSequence {
    public typealias Iterator = AnyFailableIterator<Element>

    let makeUnderlyingIterator: () -> AnyFailableIterator<Element>

    public init<FI>(_ makeUnderlyingIterator: @escaping () -> FI) where Element == FI.Element, FI : FailableIterator {
        self.makeUnderlyingIterator = {
            AnyFailableIterator(makeUnderlyingIterator())
        }
    }

    public init<FS>(_ base: FS) where FS: FailableSequence, Element == FS.Element {
        makeUnderlyingIterator = {
            AnyFailableIterator(base.makeIterator())
        }
    }

    public init() {
        makeUnderlyingIterator = { AnyFailableIterator() }
    }

    public func makeIterator() -> Iterator {
        makeUnderlyingIterator()
    }
}
