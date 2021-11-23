import XCTest
@testable import FailableSequence

final class TypeErasedTests: XCTestCase {
    func test_failableIterator_initBody() {
        var otherIterator = (0..<4).makeIterator()
        let iterator = AnyFailableIterator {
            otherIterator.next()
        }

        XCTAssertEqual(try Array(iterator), Array(0..<4))
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

}
