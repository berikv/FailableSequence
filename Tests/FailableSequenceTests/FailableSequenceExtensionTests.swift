import XCTest
@testable import FailableSequence

final class FailableSequenceExtensionTests: XCTestCase {
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

    func test_forEach() {
        do {
            var expect = 0
            try throwOnThirdElementSequence.forEach { number in
                XCTAssertEqual(number, expect)
                expect += 1
            }
        } catch {
            XCTAssert(error is MyError)
        }
    }

    func test_skipOnThrowSequence() {
        let sequence = throwOnThirdElementSequence.skipOnThrowSequence
        XCTAssertEqual(Array(sequence), [0,1,3,4,5,6,7,8,9])
    }

    func test_forceNoThrowSequence() {
        let sequence = throwOnThirdElementSequence.forceNoThrowSequence
        var iter = sequence.makeIterator()
        XCTAssertEqual(iter.next(), 0)
        XCTAssertEqual(iter.next(), 1)
    }

    func test_dropFirst() {
        let sequence = throwOnThirdElementSequence.dropFirst()
        var iter = sequence.makeIterator()
        XCTAssertEqual(try iter.next(), 1)
        XCTAssertThrowsError(try iter.next())
    }

    func test_map() throws {
        let sequence = throwOnThirdElementSequence
            .map { element in element * 2 }

        var iter = sequence.makeIterator()
        XCTAssertEqual(try iter.next(), 0)
        XCTAssertEqual(try iter.next(), 2)
        XCTAssertThrowsError(try iter.next())
    }

    func test_compactMap() throws {
        let sequence = throwOnThirdElementSequence
            .compactMap { element -> Int? in
                if element == 1 { return nil }
                return element
            }

        var iter = sequence.makeIterator()
        XCTAssertEqual(try iter.next(), 0)
        XCTAssertThrowsError(try iter.next())
    }

    func test_filter() throws {
        let sequence = throwOnThirdElementSequence
            .filter { element in element > 0 }

        var iter = sequence.makeIterator()
        XCTAssertEqual(try iter.next(), 1)
        XCTAssertThrowsError(try iter.next())
    }

}
