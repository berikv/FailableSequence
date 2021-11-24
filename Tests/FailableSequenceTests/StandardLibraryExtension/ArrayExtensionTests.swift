import XCTest
@testable import FailableSequence

final class ArrayExtensionTests: XCTestCase {
    func test_initFailableSequence() {
        let sequence = failableSequence(first: 0, next: { $0 + 1 }).prefix(3)
        XCTAssertEqual(try Array(sequence), [0, 1, 2])
    }

    func test_initFailableIterator() {
        var count = 0
        let iterator: UnfoldFailableIterator<Int> = failableIterator(next: {
            count += 1
            return count
        })
        XCTAssertEqual(try Array(iterator.prefix(3)), [1, 2, 3])
    }
}
