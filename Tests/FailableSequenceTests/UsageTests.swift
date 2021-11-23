import XCTest
@testable import FailableSequence

final class UsageTests: XCTestCase {
    struct DivisionByZero: Error {}

    func test_create() {
        let sequence = failableSequence(first: 10) { element in
            if element == 0 { throw DivisionByZero() }
            return 1 / element
        }

        do {
            try sequence.forEach { number in
                print(number)
            }
        } catch {
            print(error)
        }

        var iterator = sequence.makeIterator()
        XCTAssertEqual(try iterator.next(), 0)
        XCTAssertThrowsError(try iterator.next()) { error in
            XCTAssert(error is DivisionByZero)
        }
    }

    func test_createFromExisting() {
        let sequence = (0..<4).failableMap { number -> Int in
            if (3 - number) == 0 { throw DivisionByZero() }
            return 1 / (3 - number)
        }

        do {
            try sequence.forEach { number in
                print(number)
            }
        } catch {
            print(error)
        }
    }

    func test_intoArray() throws {
        let sequence = (0..<3).failableMap { number -> Int in
            if (3 - number) == 0 { throw DivisionByZero() }
            return 1 / (3 - number)
        }

        let array = try Array(sequence) // [0, 0, 1]
        XCTAssertEqual(array, [0, 0, 1])
    }

    func test_skipOnThrowSequence() {
        let sequence = (0..<4).failableMap { number -> Int in
            if number == 2 { throw DivisionByZero() }
            return 1 / (2 - number)
        }

        let array = Array(sequence.skipOnThrowSequence) // [0, 1, -1]
        XCTAssertEqual(array, [0, 1, -1])
    }

}
