
public protocol FailableIterator {
    associatedtype Element
    mutating func next() throws -> Element?
}

public protocol FailableSequence {
    associatedtype Element where Element == Iterator.Element
    associatedtype Iterator: FailableIterator

    func makeIterator() -> Iterator
}

public extension FailableSequence where Self == Self.Iterator {
    func makeIterator() -> Self { self }
}
