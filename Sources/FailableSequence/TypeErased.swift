
public struct AnyFailableIterator<Element>: FailableIterator {
    private let _next: () throws -> Element?

    /// Creates a failableIterator that wraps a base failableIterator but whose type depends
    /// only on the base iterator's element type.
    ///
    /// You can use `AnyFailableIterator` to hide the type signature of a more complex
    /// iterator. For example, the `digits()` function in the following example
    /// creates an iterator over a collection that lazily maps the elements of a
    /// `Range<Int>` instance to strings. Instead of returning a failableIterator with a type
    /// that encapsulates the implementation of the collection, the `digits()` function first
    /// wraps the iterator in an `AnyFailableIterator` instance.
    ///
    ///     func digits() -> AnyFailableIterator<String> {
    ///         let lazyStrings = (0..<10).failableMap { String($0) }
    ///         let iterator:
    ///             MappedFailableSequence<SequenceWrappingFailableSequence<(Range<Int>)>, String>
    ///             = lazyStrings.makeIterator()
    ///
    ///         return AnyFailableIterator(iterator)
    ///     }
    ///
    /// - Parameter base: A failableIterator to type-erase.
    public init<FI>(_ base: FI) where Element == FI.Element, FI : FailableIterator {
        var base = base
        _next = { try base.next() }
    }

    /// Creates a failableIterator that wraps the given closure in its `next()` method.
    ///
    /// The following example creates a failableIterator that counts up from the initial
    /// value of an integer `x` to 15 and throws an error when the value is 10. The
    /// error is caught in the `do`-`catch` block:
    ///
    ///     var x = 7
    ///     struct NumberIsTen: Error {}
    ///     let iterator = AnyFailableIterator {
    ///         defer { x += 1 }
    ///         if x == 10 { throw NumberIsTen() }
    ///         if x == 15 { return nil }
    ///         return x < 15 ? x : nil
    ///     }
    ///
    ///     do {
    ///         let a = try Array(iterator)
    ///     } catch {
    ///         // error is NumberIsTen
    ///     }
    ///
    /// - Parameter body: A closure that returns an optional element. `body` is
    ///   executed each time the `next()` method is called on the resulting
    ///   iterator.
    public init(_ body: @escaping () throws -> Element?) {
        _next = body
    }

    /// Creates a new, empty failableIterator.
    public init() {
        _next = { nil }
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
    public func next() throws -> Element? {
        try _next()
    }
}

public struct AnyFailableSequence<Element>: FailableSequence {

    /// A type that provides the failableSequence's iteration interface and
    /// encapsulates its iteration state.
    public typealias Iterator = AnyFailableIterator<Element>

    private let makeUnderlyingIterator: () -> AnyFailableIterator<Element>

    /// Creates a failableSequence whose `makeIterator()` method forwards to
    /// `makeUnderlyingIterator`.
    public init<FI>(_ makeUnderlyingIterator: @escaping () -> FI) where Element == FI.Element, FI : FailableIterator {
        self.makeUnderlyingIterator = {
            AnyFailableIterator(makeUnderlyingIterator())
        }
    }

    /// Creates a new failableSequence that wraps and forwards operations to `base`.
    public init<FS>(_ base: FS) where FS: FailableSequence, Element == FS.Element {
        makeUnderlyingIterator = {
            AnyFailableIterator(base.makeIterator())
        }
    }

    /// Creates a new, empty failableSequence.
    public init() {
        makeUnderlyingIterator = { AnyFailableIterator() }
    }

    /// Returns a failableIterator over the elements of this failableSequence.
    public func makeIterator() -> Iterator {
        makeUnderlyingIterator()
    }
}
