
public protocol FailableSequence {
    associatedtype Element where Element == Iterator.Element
    associatedtype Iterator: FailableIterator

    var crashOnErrorSequence: AnySequence<Element> { get }
    func makeIterator() -> Iterator
}

public struct AnyFailableSequence<Element>: FailableSequence {
    let compute: () throws -> Element?

    public init(_ compute: @escaping () throws -> Element?) {
        self.compute = compute
    }

    public var crashOnErrorSequence: AnySequence<Element> {
        AnySequence {
            makeIterator().crashOnErrorIterator
        }
    }

    public func makeIterator() -> AnyFailableIterator<Element> {
        return AnyFailableIterator(compute)
    }
}

public extension Array {
    init(_ sequence: AnyFailableSequence<Element>) throws {
        self.init()
        var iterator = sequence.makeIterator()
        while let next = try iterator.next() {
            append(next)
        }
    }
}
