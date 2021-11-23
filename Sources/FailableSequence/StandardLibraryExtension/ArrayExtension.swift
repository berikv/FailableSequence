
public extension Array {
    init<FS>(_ failableSequence: FS) throws
    where FS: FailableSequence, Element == FS.Element
    {
        try self.init(failableSequence.makeIterator())
    }
}

public extension Array {
    init<FI>(_ failableIterator: FI) throws
    where FI: FailableIterator, Element == FI.Element
    {
        self.init()
        var iterator = failableIterator
        while let next = try iterator.next() {
            append(next)
        }
    }
}

// Resolve ambiguoush initializer issue
public extension Array {
    init<FS>(_ failableSequence: FS) throws
    where FS: FailableSequence, FS: FailableIterator, Element == FS.Element
    {
        try self.init(failableSequence.makeIterator())
    }
}
