import XCTest
@testable import FailableSequence

final class FailableSequenceTests: XCTestCase {
    struct MyError: Error {}

    var throwOnThirdElementSequence: AnyFailableSequence<Int>!

    override func setUp() {
        super.setUp()

        throwOnThirdElementSequence = AnyFailableSequence(
            (0..<10).failableMap { element -> Int in
                if element == 2 { throw MyError() }
                else { return element }
            })
    }

    func test_unfoldFailableSequence_state() throws {
        let sequence = failableSequence(state: (0..<10).makeIterator()) { state -> Int? in
            guard let next = state.next() else { return nil }
            if next == 2 { throw MyError() }
            return next
        }

        var iter = sequence.makeIterator()
        XCTAssertNoThrow(try iter.next())
        XCTAssertNoThrow(try iter.next())
        XCTAssertThrowsError(try iter.next())
    }

    func test_unfoldFailableSequence_first() throws {
        let sequence = failableSequence(first: 0) { element -> Int? in
            if element == 2 { throw MyError() }
            return element + 1
        }

        var iter = sequence.makeIterator()
        XCTAssertNoThrow(try iter.next())
        XCTAssertNoThrow(try iter.next())
        XCTAssertThrowsError(try iter.next())
    }

    func test_failableMap() throws {
        let sequence = (0..<10).failableMap { element -> Int in
            if element == 2 { throw MyError() }
            else { return element }
        }

        var iter = sequence.makeIterator()
        XCTAssertNoThrow(try iter.next())
        XCTAssertNoThrow(try iter.next())
        XCTAssertThrowsError(try iter.next())
    }



    func test_failableSequence() throws {
        let s = failableSequence(state: 0) { state -> Int? in
            if state == 10 { return nil }
            state += 1
            return state
        }

        XCTAssertEqual(try Array(s).count, 10)
        XCTAssertEqual(try Array(s).count, 10)
    }

}
