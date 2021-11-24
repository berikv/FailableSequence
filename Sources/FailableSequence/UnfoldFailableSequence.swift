
public struct UnfoldFailableSequence<Element, State> : FailableSequence, FailableIterator {
    public typealias Iterator = UnfoldFailableSequence<Element, State>

    private var state: State
    private let _next: (inout State) throws -> Element?

    fileprivate init(startState: State, next: @escaping (inout State) throws -> Element?) {
        self.state = startState
        self._next = next
    }

    public mutating func next() throws -> Element? {
        try _next(&state)
    }
}

public func failableSequence<Element, State>(state: State, next: @escaping (inout State) throws -> Element?)
-> UnfoldFailableSequence<Element, State>
{
    UnfoldFailableSequence(startState: state, next: next)
}

public typealias UnfoldFirstFailableSequence<Element> = UnfoldFailableSequence<Element, (Element?, Bool)>

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

public typealias UnfoldFailableIterator<Element> = UnfoldFailableSequence<Element, Void>

public func failableIterator<Element>(next: @escaping () throws -> Element?)
-> UnfoldFailableIterator<Element>
{
    UnfoldFailableIterator(startState: ()) { _ in try next() }
}
