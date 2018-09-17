// 

import Fluent
import ContentaTools
import Foundation

extension SchemaBuilder {
    public func unique3<T, U>(on a: KeyPath<Model, T>, _ b: KeyPath<Model, U>, _ c: KeyPath<Model, U>) {
        let a = Model.Database.queryField(.keyPath(a))
        let b = Model.Database.queryField(.keyPath(b))
        let c = Model.Database.queryField(.keyPath(c))
        let unique = Model.Database.schemaUnique(on: [a, b, c])
        constraint(unique)
    }
}

public struct ContentaVersionMigration_01<D> : Migration where D: JoinSupporting & SchemaSupporting & MigrationSupporting {
    public typealias Database = D

    // MARK: - create tables
    static func prepareTablePatch(on connection: Database.Connection) -> Future<Void> {
        return Database.create(Patch.self, on: connection) { builder in
            
            //add fields
            builder.field(for: \Patch.id, isIdentifier: true)
            builder.field(for: \Patch.code)
            builder.field(for: \Patch.note)
            builder.field(for: \Patch.versionId)
            builder.field(for: \Patch.created)

            builder.reference(from: \Patch.versionId, to: \Version<Database>.id)
        }
    }

    static func prepareTableVersion(on connection: Database.Connection) -> Future<Void> {
        return Database.create(Version.self, on: connection) { builder in
            
            //add fields
            builder.field(for: \Version.id, isIdentifier: true)
            builder.field(for: \Version.code)
            builder.field(for: \Version.note)
            builder.field(for: \Version.major)
            builder.field(for: \Version.minor)
            builder.field(for: \Version.level)
            builder.field(for: \Version.created)

            // constraints
            builder.unique3(on: \Version.major, \Version.minor, \Version.level )
        }
    }

    // MARK: -
    public static func prepare(on connection: Database.Connection) -> Future<Void> {
        let allFutures : [EventLoopFuture<Void>] = [
            prepareTableVersion(on: connection),
            prepareTablePatch(on: connection),
        ]

        return Future<Void>.andAll(allFutures, eventLoop: connection.eventLoop)
    }
    
    public static func revert(on connection: Database.Connection) -> Future<Void> {
        let allFutures : [EventLoopFuture<Void>] = [
            Database.delete(Patch.self, on: connection),
            Database.delete(Version.self, on: connection),
        ]
        return Future<Void>.andAll(allFutures, eventLoop: connection.eventLoop)
    }
}
