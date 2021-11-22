
public protocol FailableIterator {
    associatedtype Element
    var crashOnErrorIterator: AnyIterator<Element> { get }
    mutating func next() throws -> Element?
}

public struct AnyFailableIterator<Element>: FailableIterator {
    let compute: () throws -> Element?

    public init(_ compute: @escaping () throws -> Element?) {
        self.compute = compute
    }

    public var crashOnErrorIterator: AnyIterator<Element> {
        AnyIterator {
            try! compute()
        }
    }

    public mutating func next() throws -> Element? {
        try compute()
    }
}
