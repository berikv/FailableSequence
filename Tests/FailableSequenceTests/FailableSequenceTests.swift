import XCTest
@testable import FailableSequence

final class FailableSequenceTests: XCTestCase {

    func test_failableSequenceAndFailableIterator() {
        var sequence = failableSequence(first: 0) { $0 + 1 }
        XCTAssertEqual(try sequence.next(), 0)
    }
}
