import XCTest
@testable import FailableSequence

final class TypeErasedTests: XCTestCase {

    func test_failableIterator_initBase() {
        var count = 0
        let other = failableIterator { () -> Int? in
            count += 1
            if count > 3 { return nil }
            return count
        }

        let iterator = AnyFailableIterator(other)

        XCTAssertEqual(try Array(iterator), [1, 2, 3])
    }

    func test_failableIterator_initBody() {
        var otherIterator = (0..<4).makeIterator()
        let iterator = AnyFailableIterator {
            otherIterator.next()
        }

        XCTAssertEqual(try Array(iterator), Array(0..<4))
    }

    func test_failableIterator_initEmpty() {
        let iterator = AnyFailableIterator<Int>()
        XCTAssertEqual(try Array(iterator), [])
    }

    func test_failableSequence_initUnderlyingIterator() {
        var otherIterator = (0..<4).makeIterator()
        let iterator = AnyFailableIterator {
            otherIterator.next()
        }
        let sequence = AnyFailableSequence {
            iterator
        }

        XCTAssertEqual(try Array(sequence), Array(0..<4))
    }

    func test_failableSequence_initBase() {
        let other = failableSequence(first: 0) { $0 + 1 }
        let sequence = AnyFailableSequence(other.prefix(3))

        XCTAssertEqual(try Array(sequence), [0, 1, 2])
    }

    func test_failableSequence_initEmpty() {
        let sequence = AnyFailableSequence<Int>()
        XCTAssertEqual(try Array(sequence), [])
    }
}
