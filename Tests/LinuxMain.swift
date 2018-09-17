import XCTest

import ContentaUserModelTests

var tests = [XCTestCaseEntry]()
tests += PatchTests.allTests()
tests += VersionTests.allTests()
XCTMain(tests)
