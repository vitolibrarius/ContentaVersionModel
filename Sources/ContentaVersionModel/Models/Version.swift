//
//  Version.swift
//

import Async
import Fluent
import Foundation
import ContentaTools

public final class Version<D>: Model where D: QuerySupporting {

    // MARK: ID
    public typealias ID = Int
    public typealias Database = D
    public static var idKey: IDKey { return \.id }

    public static var entity: String {
        return "version"
    }

    public static var createdAtKey: TimestampKey? {
        return \Version.created
    }

    // MARK: - attributes
    public var id: ID?
    public var code: String
    public var note: String?
    public var major: Int
    public var minor: Int
    public var level: Int
    public var created: Date?

    /// Creates a new `Version`.
    init(major: Int, minor: Int, level: Int) {
        self.code = "\(major).\(minor).\(level)"
        self.major = major
        self.minor = minor
        self.level = level
    }

    init(major: Int, minor: Int, level: Int, note: String) {
        self.code = "\(major).\(minor).\(level)"
        self.major = major
        self.minor = minor
        self.level = level
        self.note = note
    }
}

// MARK: - Relations

// Patch ⇇↦  Version
extension Version {
    public var patches: Children<Version, Patch<Database>> {
        return children(\Patch.versionId)
    }

    public func addPatch(_ code: String, _ notes: String, on connection: Database.Connection ) throws -> Patch<Database> {
        let patch = try Patch<Database>(code: code, version: self, note: notes)!.create(on: connection).wait()
        return patch
    }
}
