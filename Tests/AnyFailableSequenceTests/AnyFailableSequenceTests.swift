import XCTest
@testable import AnyFailableSequence

final class AnyFailableSequenceTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AnyFailableSequence().text, "Hello, World!")
    }
}
