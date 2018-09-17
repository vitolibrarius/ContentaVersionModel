//
//  PatchTest.swift
//

import Foundation
import XCTest
import FluentSQLite
import ContentaTools

@testable import ContentaVersionModel

final class PatchTest: XCTestCase {
    static var allTests = [
        ("testPatchsForeign", testPatchsForeign),
        ]
    
    override func setUp() {
        super.setUp()
    }
    
    func testPatchsForeign() {
        let file : ToolFile = sqliteDataFile("\(#function)", "\(#file)")
        do {
            if ( file.exists ) {
                try file.delete()
            }
            
            let sqlite = try SQLiteDatabase(storage: .file(path: file.fullPath))
            let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let conn = try sqlite.newConnection(on: eventLoop).wait()
            
            try ContentaVersionMigration_01<SQLiteDatabase>.prepare(on: conn).wait()
            
            try assertTableExists( "patch", conn )
            let Patchs = try Patch<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(Patchs.count, 0)
            
            let version = try Version<SQLiteDatabase>(major: 0, minor: 1, level: 3, note: "initial beta version")
                .create(on: conn).wait()
            _ = try Patch<SQLiteDatabase>(code: "ContentaVersionMigration_01", version: version, note: "created new version model")!.create(on: conn).wait()
            _ = try version.addPatch("ContentaUserMigration_01", "created new user model", on: conn)

            let Patchs2 = try Patch<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(Patchs2.count, 2)
            
            try file.delete()
        }
        catch  {
            XCTFail(error.localizedDescription)
        }
    }
}

extension PatchTest : DbTestCase {}


