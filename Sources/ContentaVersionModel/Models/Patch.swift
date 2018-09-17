//
//  Patch.swift
//

import Fluent
import Foundation
import ContentaTools

public final class Patch<D>: Model where D: QuerySupporting {
    
    // MARK: ID
    public typealias Database = D
    public typealias ID = Int
    
    public static var idKey: IDKey { return \.id }
    public static var entity: String {
        return "patch"
    }

    public static var createdAtKey: TimestampKey? {
        return \Patch.created
    }
    
    // MARK: - attributes
    public var id: Int?
    public var code: String
    public var versionId: Int
    public var note: String?
    public var created: Date?
    
    /// Creates a new `Patch`.
    init( code: String, versionId: Int ) {
        self.code = code
        self.versionId = versionId
    }

    init( code: String, versionId: Int, note : String ) {
        self.code = code
        self.versionId = versionId
        self.note = note
    }

    init?( code: String, version: Version<Database>, note : String ) throws {
        self.code = code
        self.versionId = try version.requireID()
        self.note = note
    }
}

// MARK: - Relations
extension Patch {
    public var version: Parent<Patch, Version<Database>> {
        return parent(\Patch.versionId)
    }
}

// MARK: queries
extension Patch {
}
