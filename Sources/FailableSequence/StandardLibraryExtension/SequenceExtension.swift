
public struct IteratorWrappingFailableIterator<Base>: FailableIterator where Base: IteratorProtocol {

    /// A type representing the failableSequence's elements.
    public typealias Element = Base.Element

    private var _base: Base

    fileprivate init(_ base: Base) {
        self._base = base
    }

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists. Throws an error if producing the next element fails.
    ///
    /// Repeatedly calling this method returns, in order, all the elements of the
    /// underlying sequence. As soon as the sequence has run out of elements, all
    /// subsequent calls return `nil`.
    ///
    /// You must not call this method if any other copy of this iterator has been
    /// advanced with a call to its `next()` method.
    ///
    /// The following example shows how an iterator can be used explicitly to
    /// emulate a `for`-`in` loop. First, retrieve a sequence's iterator, and
    /// then call the iterator's `next()` method until it returns `nil`.
    ///
    ///     let numbers = [2, 3, 5, 7].failable
    ///     var numbersIterator = numbers.makeIterator()
    ///
    ///     while let num = try numbersIterator.next() {
    ///         print(num)
    ///     }
    ///     // Prints "2"
    ///     // Prints "3"
    ///     // Prints "5"
    ///     // Prints "7"
    ///
    /// - Returns: The next element in the underlying sequence, if a next element
    ///   exists; otherwise, `nil`.
    public mutating func next() throws -> Base.Element? {
        _base.next()
    }
}

public struct SequenceWrappingFailableSequence<Base>: FailableSequence where Base: Sequence {

    /// A type representing the failableSequence's elements.
    public typealias Element = Base.Element

    /// A type that provides the failableSequence's iteration interface and
    /// encapsulates its iteration state.
    public typealias Iterator = IteratorWrappingFailableIterator<Base.Iterator>

    private let _base: Base

    fileprivate init(_ base: Base) {
        self._base = base
    }

    /// Returns a failableIterator over the elements of this failableSequence.
    public func makeIterator() -> IteratorWrappingFailableIterator<Base.Iterator> {
        return IteratorWrappingFailableIterator(_base.makeIterator())
    }
}

public extension Sequence {
    /// A FailableSequence containing the same elements as this failableSequence.
    var failable: SequenceWrappingFailableSequence<Self> {
        SequenceWrappingFailableSequence(self)
    }
}

public extension IteratorProtocol {
    /// A FailableSequence containing the same elements as this failableSequence.
    var failable: IteratorWrappingFailableIterator<Self> {
        IteratorWrappingFailableIterator(self)
    }
}

// Resolve ambiguoush initializer issue
public extension Sequence where Self == Self.Iterator {
    /// A FailableSequence containing the same elements as this failableSequence.
    var failable: IteratorWrappingFailableIterator<Self> {
        IteratorWrappingFailableIterator(self)
    }
}

public extension Sequence {
    /// Returns a failableSequence containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// In this example, `failableMap` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters. The failableSequence
    /// will throw an error if "Elia" is found to be part of the cast.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let lowercaseNames = cast.failableMap { name in
    ///         if name == "Elia" { throw NotPartOfCast() }
    ///         return name.lowercased()
    ///     }
    ///     // 'try Array(lowercaseNames)' == ["vivien", "marlon", "kim", "karl"]
    ///
    ///     let letterCounts = cast.map { $0.count }
    ///     // 'try Array(letterCounts)' == [6, 6, 3, 4]
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and returns a transformed
    ///   value of the same or of a different type. `transform` can throw an error.
    ///   Because `transform` is called when the next element is asked for, the
    ///   throw happens when that element is requested, not when `map` is invoked.
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    func failableMap<ElementOfResult>(_ transform: @escaping (Element) throws -> ElementOfResult) -> MappedFailableSequence<SequenceWrappingFailableSequence<Self>, ElementOfResult> {
        failable.map(transform)
    }
}

