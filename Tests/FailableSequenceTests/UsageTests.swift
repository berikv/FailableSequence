import XCTest
@testable import FailableSequence

/// Test class that validates the code in the project Readme.md
final class UsageTests: XCTestCase {
    struct NumberIsThreeError: Error {}

    func test_create() {
        let sequence = failableSequence(first: 0) { number in
            let next = number + 1
            if next == 3 { throw NumberIsThreeError() }
            return next
        }

        var numbers = [Int]()
        var theError: Error?

        do {
            try sequence.forEach { numbers.append($0) }
        } catch {
            theError = error
        }

        // numbers == [0, 1]
        // error is NumberIsThreeError

        XCTAssertEqual(numbers, [0, 1])
        XCTAssert(theError is NumberIsThreeError)
    }

    func test_createFromExisting() {
        let sequence = (0..<4).failableMap { number -> Int in
            let next = number + 1
            if next == 3 { throw NumberIsThreeError() }
            return next
        }

        var numbers = [Int]()
        var theError: Error?

        do {
            try sequence.forEach { numbers.append($0) }
        } catch {
            theError = error
        }

        // numbers == [1, 2]
        // error is NumberIsThreeError

        XCTAssertEqual(numbers, [1, 2])
        XCTAssert(theError is NumberIsThreeError)
    }

    func test_intoArray() throws {
        // Note, if this sequence would cause the *Array init* to throw an error if number == 3.
        let sequence = failableSequence(first: 0) { number in
            let next = number + 1
            if next == 3 { throw NumberIsThreeError() }
            return next
        }

        let array = try Array(sequence.prefix(2))
        // array == [0, 1]

        XCTAssertEqual(array, [0, 1])
    }

    func test_skipOnThrowSequence() {
        let sequence = (0...4).failableMap { number -> Int in
            let next = number + 1
            if next == 3 { throw NumberIsThreeError() }
            return next
        }

        let array = Array(sequence.skipOnThrowSequence)
        // array == [1, 2, 4, 5]

        XCTAssertEqual(array, [1, 2, 4, 5])
    }
}
