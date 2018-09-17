import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VersionTests.allTests),
        testCase(PatchTests.allTests),
    ]
}
#endif
