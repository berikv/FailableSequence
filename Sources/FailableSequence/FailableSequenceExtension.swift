
public extension FailableSequence {
    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    ///
    /// FailableSequence can't be used in a`for`-`in` loop like a Sequence.
    /// The two loops in the following example produce the same output:
    ///
    ///     let numberWords = ["one", "two", "three"]
    ///     for word in numberWords {
    ///         print(word)
    ///     }
    ///     // Prints "one"
    ///     // Prints "two"
    ///     // Prints "three"
    ///
    ///     try numberWords.failable.forEach { word in
    ///         print(word)
    ///     }
    ///     // Same as above
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    /// 3. While iterating over the failableSequence an error could happen, which is
    /// thrown by the `forEach` method.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a
    ///   parameter.
    func forEach(_ body: (Element) throws -> Void) throws {
        var iterator = makeIterator()
        while let element = try iterator.next() {
            try body(element)
        }
    }
}

public extension FailableSequence {
    /// A sequence that produces the same elements as this instance, triggering
    /// a runtime error if the failableSequence throws an error.
    var forceNoThrowSequence: UnfoldSequence<Element, Iterator> {
        var iterator = makeIterator()
        return sequence(state: makeIterator()) { state in
            try! iterator.next()
        }
    }
}

public extension FailableSequence {
    /// A sequence that produces the same elements as this instance, skipping
    /// elements that threw an error.
    ///
    /// - Note: A failableSequence that throws an infinite stream of errors will
    ///   cause `failableSequence.skipOnThrowSequence.next()` to
    ///   endlessly spin and never return.
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
    /// A type representing the failableSequence's elements.
    public typealias Element = Base.Element

    private var base: Base
    private var dropCount: Int
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, dropCount: Int) {
        precondition(dropCount >= 0)
        self.base = base
        self.dropCount = dropCount
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
    public mutating func next() throws -> Element? {
        while dropCount > 0 {
            guard try iterator.next() != nil else { return nil }
            dropCount -= 1
        }

        return try iterator.next()
    }
}

public extension FailableSequence {
    /// Returns a failableSequence containing all but the given number of initial
    /// elements.
    ///
    /// If the number of elements to drop exceeds the number of elements in
    /// the sequence, the result is an empty sequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5].failable
    ///     print(try Array(numbers.dropFirst(2)))
    ///     // Prints "[3, 4, 5]"
    ///     print(try Array(numbers.dropFirst(10)))
    ///     // Prints "[]"
    ///
    /// - Parameter k: The number of elements to drop from the beginning of
    ///   the sequence. `k` must be greater than or equal to zero.
    /// - Returns: A sequence starting after the specified number of
    ///   elements.
    ///
    /// - Complexity: O(1), with O(*k*) deferred to the first iteration of the result,
    ///   where *k* is the number of elements to drop from the beginning of
    ///   the sequence.
    func dropFirst(_ k: Int = 1) -> DropFirstFailableSequence<Self> {
        DropFirstFailableSequence(self, dropCount: k)
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
    public mutating func next() throws -> Element? {
        guard let element = try iterator.next() else { return nil }
        return try transform(element)
    }
}

public extension FailableSequence {
    /// Returns a failableSequence containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// In this example, `map` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters. The failableSequence
    /// will throw an error if "Elia" is found to be part of the cast.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"].failable
    ///     let lowercaseNames = cast.map { name in
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
    public mutating func next() throws -> Element? {
        while true {
            guard let element = try iterator.next() else { return nil }
            guard let result = try transform(element) else { continue }
            return result
        }
    }
}

public extension FailableSequence {
    /// Returns the non-`nil` results of mapping the given transformation over
    /// this failableSequence.
    ///
    /// Use this method to receive a failableSequence of non-optional values when your
    /// transformation produces an optional value.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence
    ///   as its argument and returns an optional value.
    ///
    /// - Complexity: O(1)
    func compactMap<ElementOfResult>(_ transform: @escaping (Self.Element) throws -> ElementOfResult?) -> CompactMappedFailableSequence<Self, ElementOfResult> {
        CompactMappedFailableSequence(self, transform: transform)
    }
}

public struct FilteredFailableSequence<Base>: FailableSequence, FailableIterator
where Base: FailableSequence
{
    /// A type representing the failableSequence's elements.
    public typealias Element = Base.Element

    private var base: Base
    private let isIncluded: (Base.Element) throws -> Bool
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, isIncluded: @escaping (Base.Element) throws -> Bool) {
        self.base = base
        self.isIncluded = isIncluded
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
    public mutating func next() throws -> Element? {
        while true {
            guard let element = try iterator.next() else { return nil }
            guard try isIncluded(element) else { continue }
            return element
        }
    }
}

public extension FailableSequence {
    /// Returns the elements of `self` that satisfy `isIncluded`.
    func filter(_ isIncluded: @escaping (Element) throws -> Bool) rethrows -> FilteredFailableSequence<Self> {
        FilteredFailableSequence(self, isIncluded: isIncluded)
    }
}

public struct PrefixFailableSequence<Base>: FailableSequence, FailableIterator where Base: FailableSequence {

    /// A type representing the failableSequence's elements.
    public typealias Element = Base.Element

    private var base: Base
    private var maxLength: Int
    private lazy var iterator = base.makeIterator()

    fileprivate init(_ base: Base, maxLength: Int) {
        self.base = base
        self.maxLength = maxLength
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
    public mutating func next() throws -> Element? {
        if maxLength == 0 { return nil }
        maxLength -= 1
        return try iterator.next()
    }
}

public extension FailableSequence {
    /// Returns a failableSequence, up to the specified maximum length, containing the
    /// initial elements of the failableSequence.
    ///
    /// If the maximum length exceeds the number of elements in the failableSequence,
    /// the result contains all the elements in the failableSequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5].failable
    ///     print(try Array(numbers.prefix(2)))
    ///     // Prints "[1, 2]"
    ///     print(try Array(numbers.prefix(10)))
    ///     // Prints "[1, 2, 3, 4, 5]"
    ///
    /// - Parameter maxLength: The maximum number of elements to return. The
    ///   value of `maxLength` must be greater than or equal to zero.
    /// - Returns: A sequence starting at the beginning of this sequence
    ///   with at most `maxLength` elements.
    ///
    /// - Complexity: O(1)
    func prefix(_ maxLength: Int) -> PrefixFailableSequence<Self> {
        PrefixFailableSequence(self, maxLength: maxLength)
    }
}
