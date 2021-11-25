
/// A type that supplies the values of a sequence one at a time, or throws an error
/// if producing a value failed.
///
/// The `FailableIterator` protocol is tightly linked with the `FailableSequence`
/// protocol. Sequences provide access to their elements by creating an
/// iterator, which keeps track of its iteration process and returns one
/// element at a time as it advances through the sequence.
///
/// `FailableIterator` is different from the Swift standard library
/// `IteratorProtocol`in important ways:
///
/// First, failable iterators `next` method can throw. As such the `FailableIterator`
/// can be used to better model sequences like data streams.
/// Second, Swift `for`-`in` loops do not support `FailableIterator`. Instead use
/// the `forEach` method to iterate on the values.
public protocol FailableIterator {
    associatedtype Element

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
    mutating func next() throws -> Element?
}

/// A type that provides sequential, iterated access to its elements. Retreiving
/// an element from a failableSequence may throw an error.
///
/// Repeated Access
/// ===============
///
/// The `FailableSequence` protocol makes no requirement on conforming types regarding
/// whether they will be destructively consumed by iteration. As a
/// consequence, don't assume that multiple `forEach` calls on a failableSequence
/// will either resume iteration or restart from the beginning:
///
///     try sequence.forEach { element in
///         if ... some condition { return }
///     }
///
///     try sequence.forEach { element in
///         // No defined behavior
///     }
///
/// In this case, you cannot assume either that a sequence will be consumable
/// and will resume iteration, or that a sequence will restart iteration from the
/// first element. A conforming sequence is allowed to produce an arbitrary
/// sequence of elements in the second `forEach` loop.
///
/// Conforming to the FailableSequence Protocol
/// ===================================
///
/// Making your own custom types conform to `FailableSequence` enables many useful
/// operations, like `forEach` looping and the `contains` method, without
/// much effort. To add `FailableSequence` conformance to your own custom type, add a
/// `makeIterator()` method that returns an iterator.
///
/// Alternatively, if your type can act as its own iterator, implementing the
/// requirements of the `FailableIterator` protocol and declaring conformance
/// to both `FailableSequence` and `FailableIterator` are sufficient.
///
/// Here's a definition of a `Countdown` sequence that serves as its own
/// iterator. The `makeIterator()` method is provided as a default
/// implementation.
///
///     struct Countdown: FailableSequence, FailableIterator {
///         var count: Int
///
///         mutating func next() throws -> Int? {
///             if count == 0 {
///                 return nil
///             } if count > 5 {
///                 throw CountOutOfBounds()
///             } else {
///                 defer { count -= 1 }
///                 return count
///             }
///         }
///     }
///
///     let threeToGo = Countdown(count: 3)
///     try threeToGo.forEach { i in
///         print(i)
///     }
///     // Prints "3"
///     // Prints "2"
///     // Prints "1"
///
/// Expected Performance
/// ====================
///
/// A failableSequence should provide its iterator in O(1). The `FailableSequence`
/// protocol makes no other requirements about element access, so routines that
/// traverse a sequence should be considered O(*n*) unless documented
/// otherwise.
public protocol FailableSequence {
    associatedtype Element where Element == Iterator.Element
    associatedtype Iterator: FailableIterator

    /// Returns a failableIterator over the elements of this failableSequence.
    func makeIterator() -> Iterator
}

public extension FailableSequence where Self == Self.Iterator {
    /// Returns a failableIterator over the elements of this failableSequence.
    func makeIterator() -> Self { self }
}
