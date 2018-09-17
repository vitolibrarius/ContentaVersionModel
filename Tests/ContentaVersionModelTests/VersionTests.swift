//
//  VersionTest.swift
//

import Foundation
import XCTest
import FluentSQLite
import ContentaTools

@testable import ContentaVersionModel

final class VersionTests: XCTestCase {
    static var allTests = [
        ("testMigration", testMigration),
        ("testInserts", testInserts),
        ("testUnique", testUnique)
    ]
    
    override func setUp() {
        super.setUp()
    }

    func testMigration() {
        let file : ToolFile = sqliteDataFile("\(#function)", "\(#file)")
        do {
            if ( file.exists ) {
                try file.delete()
            }

            let sqlite = try SQLiteDatabase(storage: .file(path: file.fullPath))
            let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let conn = try sqlite.newConnection(on: eventLoop).wait()

            try ContentaVersionMigration_01<SQLiteDatabase>.prepare(on: conn).wait()

            try assertTableExists( "version", conn )
            let versions = try Version<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(versions.count, 0)

            let patches = try Patch<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(patches.count, 0)
            try file.delete()
        }
        catch  {
            XCTFail(error.localizedDescription)
        }
    }

    func testInserts() {
        let file : ToolFile = sqliteDataFile("\(#function)", "\(#file)")
        do {
            if ( file.exists ) {
                try file.delete()
            }
            
            let sqlite = try SQLiteDatabase(storage: .file(path: file.fullPath))
            let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let conn = try sqlite.newConnection(on: eventLoop).wait()
            
            try ContentaVersionMigration_01<SQLiteDatabase>.prepare(on: conn).wait()
            
            try assertTableExists( "version", conn )
            let versions = try Version<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(versions.count, 0)
            
            let patches = try Patch<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(patches.count, 0)
            
            _ = try Version<SQLiteDatabase>(major: 0, minor: 1, level: 3, note: "initial beta version")
                .create(on: conn).wait()
            _ = try Version<SQLiteDatabase>(major: 1, minor: 0, level: 7, note: "production release")
                .create(on: conn).wait()

            let version_new = try Version<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(version_new.count, 2)

            try file.delete()
        }
        catch  {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnique() {
        let file : ToolFile = sqliteDataFile("\(#function)", "\(#file)")
        do {
            if ( file.exists ) {
                try file.delete()
            }
            
            let sqlite = try SQLiteDatabase(storage: .file(path: file.fullPath))
            let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let conn = try sqlite.newConnection(on: eventLoop).wait()
            
            try ContentaVersionMigration_01<SQLiteDatabase>.prepare(on: conn).wait()
            
            try assertTableExists( "version", conn )
            let versions = try Version<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(versions.count, 0)
            
            let patches = try Patch<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(patches.count, 0)

            _ = try Version<SQLiteDatabase>(major: 0, minor: 1, level: 3, note: "initial beta version")
                .create(on: conn).wait()

            XCTAssertThrowsError(
                _ = try Version<SQLiteDatabase>(major: 0, minor: 1, level: 3, note: "duplicate").create(on: conn).wait()
            )
            
            XCTAssertNoThrow(
                _ = try Version<SQLiteDatabase>(major: 0, minor: 1, level: 4, note: "level bump").create(on: conn).wait()
            )
            
            let version_new = try Version<SQLiteDatabase>.query(on: conn).all().wait()
            XCTAssertEqual(version_new.count, 2)
            
            try file.delete()
        }
        catch  {
            XCTFail(error.localizedDescription)
        }
    }
}

extension VersionTests : DbTestCase {}

