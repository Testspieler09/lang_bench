package main

import (
	"database/sql"
	"fmt"
	"math/rand"
	"os"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// RunDBCRUD performs inserts, selects, updates, deletes on the SQLite DB
func RunDBCRUD(dbPath string, size int) (uint64, error) {
	// Open the database with busy timeout to avoid "database is locked"
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return 0, err
	}
	defer db.Close()

	var checksum uint64
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))

	// =====================
	// DROP & CREATE TABLES
	// =====================
	schemaBytes, err := os.ReadFile("shared/schema.sql")
	if err != nil {
		return 0, fmt.Errorf("failed to read schema file: %w", err)
	}
	if _, err := db.Exec(string(schemaBytes)); err != nil {
		return 0, fmt.Errorf("failed to execute schema: %w", err)
	}

	// =====================
	// INSERT USERS
	// =====================
	tx, err := db.Begin()
	if err != nil {
		return 0, err
	}

	for i := range size {
		username := fmt.Sprintf("user%d", i)
		email := fmt.Sprintf("user%d-%d@example.com", i, time.Now().UnixNano())
		if _, err := tx.Exec("INSERT INTO users (username, email) VALUES (?, ?)", username, email); err != nil {
			tx.Rollback()
			return 0, err
		}
	}
	if err := tx.Commit(); err != nil {
		return 0, err
	}

	// =====================
	// INSERT POSTS per USER
	// =====================
	tx, _ = db.Begin()
	for userID := 1; userID <= size; userID++ {
		for j := range 3 {
			title := fmt.Sprintf("Post %d-%d", userID, j)
			content := fmt.Sprintf("Content for post %d-%d", userID, j)
			if _, err := tx.Exec("INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)", userID, title, content); err != nil {
				tx.Rollback()
				return 0, err
			}
		}
	}
	if err := tx.Commit(); err != nil {
		return 0, err
	}

	// =====================
	// INSERT COMMENTS per POST
	// =====================
	tx, _ = db.Begin()
	for postID := 1; postID <= size*3; postID++ {
		for range 2 {
			userID := rng.Intn(size) + 1
			content := fmt.Sprintf("Comment on post %d by user %d", postID, userID)
			if _, err := tx.Exec("INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)", postID, userID, content); err != nil {
				tx.Rollback()
				return 0, err
			}
		}
	}
	if err := tx.Commit(); err != nil {
		return 0, err
	}

	// =====================
	// INSERT TAGS and POST_TAGS
	// =====================
	tx, _ = db.Begin()
	for tagID := 1; tagID <= 10; tagID++ {
		tagName := fmt.Sprintf("tag%d", tagID)
		if _, err := tx.Exec("INSERT INTO tags (name) VALUES (?)", tagName); err != nil {
			tx.Rollback()
			return 0, err
		}
	}
	if err := tx.Commit(); err != nil {
		return 0, err
	}

	tx, _ = db.Begin()
	for postID := 1; postID <= size*3; postID++ {
		for tagID := 1; tagID <= 3; tagID++ {
			if _, err := tx.Exec("INSERT INTO post_tags (post_id, tag_id) VALUES (?, ?)", postID, tagID); err != nil {
				tx.Rollback()
				return 0, err
			}
		}
	}
	if err := tx.Commit(); err != nil {
		return 0, err
	}

	// =====================
	// SELECT + UPDATE
	// =====================
	rows, err := db.Query("SELECT id, username FROM users")
	if err != nil {
		return 0, err
	}
	defer rows.Close()

	tx, _ = db.Begin()
	for rows.Next() {
		var id int
		var username string
		if err := rows.Scan(&id, &username); err != nil {
			tx.Rollback()
			return 0, err
		}
		newUsername := fmt.Sprintf("%s-updated", username)
		if _, err := tx.Exec("UPDATE users SET username=? WHERE id=?", newUsername, id); err != nil {
			tx.Rollback()
			return 0, err
		}
		checksum += uint64(id)
	}
	if err := tx.Commit(); err != nil {
		return 0, err
	}

	// =====================
	// DELETE some COMMENTS
	// =====================
	if _, err := db.Exec("DELETE FROM comments WHERE id % 2 = 0"); err != nil {
		return 0, err
	}

	return checksum, nil
}
