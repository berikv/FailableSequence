
public struct UnfoldFailableSequence<Element, State> : FailableSequence, FailableIterator {
    public typealias Iterator = UnfoldFailableSequence<Element, State>

    let startState: State
    var state: State
    let _next: (inout State) throws -> Element?

    init(startState: State, next: @escaping (inout State) throws -> Element?) {
        self.startState = startState
        self.state = startState
        self._next = next
    }

    public func makeIterator() -> Iterator {
        UnfoldFailableSequence(startState: startState, next: _next)
    }

    public mutating func next() throws -> Element? {
        try _next(&state)
    }
}

public typealias UnfoldFirstFailableSequence<Element> = UnfoldFailableSequence<Element, (Element?, Bool)>


public func failableSequence<Element, State>(state: State, next: @escaping (inout State) throws -> Element?) -> UnfoldFailableSequence<Element, State> {
    return UnfoldFailableSequence(startState: state, next: next)
}

public func failableSequence<Element>(first: Element, next: @escaping (Element) throws -> Element?) -> UnfoldFirstFailableSequence<Element> {
    let state = (first, true)

    return UnfoldFailableSequence(startState: state) { state in
        guard let element = state.0 else { return nil }
        state = (try next(element), true)
        return state.0
    }
}
