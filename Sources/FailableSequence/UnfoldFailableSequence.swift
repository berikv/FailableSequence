import Foundation

/// A sequence whose elements are produced via repeated applications of a
/// closure to some mutable state.
///
/// The elements of the sequence are computed lazily and the sequence may
/// potentially be infinite in length.
///
/// Instances of `UnfoldFailableSequence` are created with the functions
/// `failableSequence(first:next:)` and `failableSequence(state:next:)`.
public struct UnfoldFailableSequence<Element, State> : FailableSequence, FailableIterator {

    /// A type that provides the failableSequence's iteration interface and
    /// encapsulates its iteration state.
    public typealias Iterator = UnfoldFailableSequence<Element, State>

    private var state: State
    private let _next: (inout State) throws -> Element?

    fileprivate init(startState: State, next: @escaping (inout State) throws -> Element?) {
        self.state = startState
        self._next = next
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
        try _next(&state)
    }
}

/// Returns a failableSequence formed from repeated lazy applications of `next` to a
/// mutable `state`.
///
/// The elements of the failableSequence are obtained by invoking `next` with a mutable
/// state. The same state is passed to all invocations of `next`, so subsequent
/// calls will see any mutations made by previous calls. The sequence ends when
/// `next` returns `nil`. If `next` never returns `nil`, the sequence is
/// infinite. `next` may throw an error.
///
/// This function can be used to replace many instances of `AnyFailableIterator` that
/// wrap a closure.
///
/// Example:
///
///     // Interleave two sequences that yield the same element type
///     failableSequence(state: (false, seq1.makeIterator(), seq2.makeIterator()), next: { iters in
///       iters.0 = !iters.0
///       return iters.0 ? iters.1.next() : iters.2.next()
///     })
///
/// - Parameter state: The initial state that will be passed to the closure.
/// - Parameter next: A closure that accepts an `inout` state and returns the
///   next element of the sequence.
/// - Returns: A failableSequence that yields each successive value from `next`.
public func failableSequence<Element, State>(state: State, next: @escaping (inout State) throws -> Element?)
-> UnfoldFailableSequence<Element, State>
{
    UnfoldFailableSequence(startState: state, next: next)
}

/// The return type of `failableSequence(first:next:)`.
public typealias UnfoldFirstFailableSequence<Element> = UnfoldFailableSequence<Element, (Element?, Bool)>

/// Returns a failableSequence formed from `first` and repeated lazy applications of
/// `next`.
///
/// The first element in the sequence is always `first`, and each successive
/// element is the result of invoking `next` with the previous element. The
/// sequence ends when `next` returns `nil`. If `next` never returns `nil`, the
/// sequence is infinite. `next` may throw an error.
///
/// Example:
///
///     failableSequence(first: 0, next: { element in
///         if element >= 1024 { throw OutOfBound() }
///         return element + 1
///     })
///
/// - Parameter first: The first element to be returned from the sequence.
/// - Parameter next: A closure that accepts the previous sequence element and
///   returns the next element.
/// - Returns: A failableSequence that starts with `first` and continues with every
///   value returned by passing the previous element to `next`.
public func failableSequence<Element>(first: Element, next: @escaping (Element) throws -> Element?)
-> UnfoldFirstFailableSequence<Element>
{
    let state = (first, true)

    return UnfoldFailableSequence(startState: state) { state in
        let last = state.0
        if let element = state.0 {
            state = (try next(element), true)
        } else {
            state = (nil, false)
        }
        return last
    }
}

/// The return type of `failableIterator(next:)`.
public typealias UnfoldFailableIterator<Element> = UnfoldFailableSequence<Element, Void>

/// Returns a failableIterator by repeated lazy applications of `next`.
///
/// This function can be used to create an iterator that can fail with the production of
/// each element.
///
/// Example:
///
///     var buffer = Data()
///
///     failableIterator {
///         while true {
///             if let newlineIndex = buffer.firstIndex(of: UInt8("\n".utf8.first!)) {
///                 defer { buffer = buffer[newlineIndex...] }
///                 return String(data: buffer[...newlineIndex], encoding: .utf8)
///             }
///
///             if let data = try fh.read(upToCount: 1024) {
///                 buffer += data
///             } else if buffer.isEmpty {
///                 return nil
///             }
///         }
///     }
///
/// - Parameter next: A closure that returns the next element or throws an error.
public func failableIterator<Element>(next: @escaping () throws -> Element?)
-> UnfoldFailableIterator<Element>
{
    UnfoldFailableIterator(startState: ()) { _ in try next() }
}
