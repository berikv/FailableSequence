import XCTest
@testable import FailableSequence

final class SequenceExtensionTests: XCTestCase {
    struct MyError: Error {}

    func test_first() {
        let s = sequence(first: 0, next: { $0 + 1 })
        XCTAssertEqual(Array(s.prefix(3)), [0, 1, 2])

        let fs = failableSequence(first: 0, next: { $0 + 1 })
        XCTAssertEqual(try Array(fs.prefix(3)), [0, 1, 2])
    }

    func test_state() {
        let fs = failableSequence(state: 0) { state -> Int? in
            defer { state += 1 }
            return state
        }

        XCTAssertEqual(try Array(fs.prefix(3)), [0, 1, 2])
    }

    func test_nilStream() throws {
        let fs = failableSequence(state: Optional<Int>.none) { state -> Int?? in
            state = state == nil ? 1 : nil
            return state
        }

        XCTAssertEqual(try Array(fs.prefix(3)), [1, nil, 1])
    }

    func test_failable() throws {
        var sequence = (0..<10)
            .failable
            .map { element -> Int? in
                if element == 2 { throw MyError() }
                else { return element }
            }

        XCTAssertEqual(try sequence.next(), 0)
        XCTAssertEqual(try sequence.next(), 1)
        XCTAssertThrowsError(try sequence.next())
    }

    func test_iteratorFailable() throws {
        struct NotSequenceIterator: IteratorProtocol {
            typealias Element = Int
            var count = 0

            mutating func next() -> Int? {
                defer { count += 1 }
                return count
            }
        }

        var iterator = NotSequenceIterator(count: 0).failable

        XCTAssertEqual(try iterator.next(), 0)
        XCTAssertEqual(try iterator.next(), 1)
    }

    func test_iteratorSequenceFailable() throws {
        var count = 0
        var iterator = AnyIterator<Int>({
            defer { count += 1 }
            return count
        }).failable

        XCTAssertEqual(try iterator.next(), 0)
        XCTAssertEqual(try iterator.next(), 1)
    }

    func test_failableMap() throws {
        let sequence = (0..<10)
            .failableMap { element -> Int in
                if element == 2 { throw MyError() }
                else { return element }
            }

        var iter = sequence.makeIterator()
        XCTAssertNoThrow(try iter.next())
        XCTAssertNoThrow(try iter.next())
        XCTAssertThrowsError(try iter.next())
    }
}
