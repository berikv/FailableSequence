
public extension Array {
    /// Creates a new instance of an Array containing the elements of a
    /// sequence. The initializer throws an error if iterating failableSequence
    /// throws an error.
    ///
    /// - Parameter failableSequence: The failableSequence of elements for the new collection.
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    init<FS>(_ failableSequence: FS) throws
    where FS: FailableSequence, Element == FS.Element
    {
        try self.init(failableSequence.makeIterator())
    }
}

public extension Array {
    /// Creates a new instance of an Array containing the elements of a
    /// sequence. The initializer throws an error if iterating failableIterator
    /// throws an error.
    ///
    /// - Parameter failableIterator: The failableIterator of elements for the new collection.
    /// - Complexity: O(*n*), where *n* is the length of the iterator.
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
    /// Creates a new instance of an Array containing the elements of a
    /// sequence. The initializer throws an error if iterating failableIterator
    /// throws an error.
    ///
    /// - Parameter failableIterator: The failableIterator of elements for the new collection.
    /// - Complexity: O(*n*), where *n* is the length of the iterator.
    init<FS>(_ failableSequence: FS) throws
    where FS: FailableSequence, FS: FailableIterator, Element == FS.Element
    {
        try self.init(failableSequence.makeIterator())
    }
}
