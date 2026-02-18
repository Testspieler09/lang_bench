import Foundation
import SQLite3

func runDBCRUD(dbPath: String, size: Int) throws -> UInt64 {
    var db: OpaquePointer?
    var checksum: UInt64 = 0

    // Open DB
    if sqlite3_open(dbPath, &db) != SQLITE_OK {
        throw NSError(domain: "SQLite", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Unable to open database"
        ])
    }
    defer { sqlite3_close(db) }

    // =====================
    // LOAD SCHEMA
    // =====================
    let schemaPath = "shared/schema.sql"
    let schemaSQL = try String(contentsOfFile: schemaPath, encoding: .utf8)

    if sqlite3_exec(db, schemaSQL, nil, nil, nil) != SQLITE_OK {
        throw NSError(domain: "SQLite", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Failed to execute schema"
        ])
    }

    // Helper for transactions
    func begin() {
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
    }

    func commit() {
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    // =====================
    // INSERT USERS
    // =====================
    begin()
    for i in 0..<size {
        let username = "user\(i)"
        let email = "user\(i)-\(Date().timeIntervalSince1970)@example.com"

        let sql = "INSERT INTO users (username, email) VALUES (?, ?)"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, username, -1, nil)
        sqlite3_bind_text(stmt, 2, email, -1, nil)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    commit()

    // =====================
    // INSERT POSTS
    // =====================
    begin()
    for userID in 1...size {
        for j in 0..<3 {
            let title = "Post \(userID)-\(j)"
            let content = "Content for post \(userID)-\(j)"

            let sql = "INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)"
            var stmt: OpaquePointer?
            sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
            sqlite3_bind_int(stmt, 1, Int32(userID))
            sqlite3_bind_text(stmt, 2, title, -1, nil)
            sqlite3_bind_text(stmt, 3, content, -1, nil)
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
        }
    }
    commit()

    // =====================
    // INSERT COMMENTS
    // =====================
    begin()
    for postID in 1...(size * 3) {
        for _ in 0..<2 {
            let userID = Int.random(in: 1...size)
            let content = "Comment on post \(postID) by user \(userID)"

            let sql = "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)"
            var stmt: OpaquePointer?
            sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
            sqlite3_bind_int(stmt, 1, Int32(postID))
            sqlite3_bind_int(stmt, 2, Int32(userID))
            sqlite3_bind_text(stmt, 3, content, -1, nil)
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
        }
    }
    commit()

    // =====================
    // INSERT TAGS
    // =====================
    begin()
    for tagID in 1...10 {
        let tagName = "tag\(tagID)"

        let sql = "INSERT INTO tags (name) VALUES (?)"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, tagName, -1, nil)
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)
    }
    commit()

    // =====================
    // INSERT POST_TAGS
    // =====================
    begin()
    for postID in 1...(size * 3) {
        for tagID in 1...3 {
            let sql = "INSERT INTO post_tags (post_id, tag_id) VALUES (?, ?)"
            var stmt: OpaquePointer?
            sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
            sqlite3_bind_int(stmt, 1, Int32(postID))
            sqlite3_bind_int(stmt, 2, Int32(tagID))
            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
        }
    }
    commit()

    // =====================
    // SELECT + UPDATE
    // =====================
    var selectStmt: OpaquePointer?
    sqlite3_prepare_v2(db, "SELECT id, username FROM users", -1, &selectStmt, nil)

    var users: [(Int, String)] = []

    while sqlite3_step(selectStmt) == SQLITE_ROW {
        let id = Int(sqlite3_column_int(selectStmt, 0))
        let username = String(cString: sqlite3_column_text(selectStmt, 1))
        users.append((id, username))
    }
    sqlite3_finalize(selectStmt)

    begin()
    for (id, username) in users {
        let newUsername = "\(username)-updated"
        let sql = "UPDATE users SET username=? WHERE id=?"
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, newUsername, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(id))
        sqlite3_step(stmt)
        sqlite3_finalize(stmt)

        checksum &+= UInt64(id)
    }
    commit()

    // =====================
    // DELETE some COMMENTS
    // =====================
    sqlite3_exec(db, "DELETE FROM comments WHERE id % 2 = 0", nil, nil, nil)

    return checksum
}
