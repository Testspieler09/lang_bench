use rand::RngExt;
use rusqlite::{Connection, Result, params};
use std::fs;
use std::path::Path;

/// Run DB CRUD benchmark
pub fn run(db_path: &Path, size: usize) -> Result<u64> {
    // Open connection with busy timeout to avoid "database is locked"
    let mut conn = Connection::open(db_path)?;

    let mut checksum: u64 = 0;
    let mut rng = rand::rng();

    // =====================
    // LOAD SCHEMA FROM FILE
    // =====================
    let schema = fs::read_to_string("shared/schema.sql")
        .map_err(|_| rusqlite::Error::InvalidPath("shared/schema.sql".into()))?;
    conn.execute_batch(&schema)?;

    // =====================
    // INSERT USERS
    // =====================
    let tx = conn.transaction()?;
    for i in 0..size {
        let username = format!("user{}", i);
        // Append nanos to make email unique per run
        let email = format!(
            "user{}-{}@example.com",
            i,
            chrono::Utc::now().timestamp_nanos_opt().unwrap()
        );
        tx.execute(
            "INSERT INTO users (username, email) VALUES (?1, ?2)",
            params![username, email],
        )?;
    }
    tx.commit()?;

    // =====================
    // INSERT POSTS per USER
    // =====================
    let tx = conn.transaction()?;
    for user_id in 1..=size as i64 {
        for j in 0..3 {
            let title = format!("Post {}-{}", user_id, j);
            let content = format!("Content for post {}-{}", user_id, j);
            tx.execute(
                "INSERT INTO posts (user_id, title, content) VALUES (?1, ?2, ?3)",
                params![user_id, title, content],
            )?;
        }
    }
    tx.commit()?;

    // =====================
    // INSERT COMMENTS per POST
    // =====================
    let tx = conn.transaction()?;
    for post_id in 1..=(size * 3) as i64 {
        for _ in 0..2 {
            let user_id = rng.random_range(1..=size as i64);
            let content = format!("Comment on post {} by user {}", post_id, user_id);
            tx.execute(
                "INSERT INTO comments (post_id, user_id, content) VALUES (?1, ?2, ?3)",
                params![post_id, user_id, content],
            )?;
        }
    }
    tx.commit()?;

    // =====================
    // INSERT TAGS and POST_TAGS
    // =====================
    let tx = conn.transaction()?;
    for tag_id in 1..=10 {
        let tag_name = format!("tag{}", tag_id);
        tx.execute("INSERT INTO tags (name) VALUES (?1)", params![tag_name])?;
    }
    tx.commit()?;

    let tx = conn.transaction()?;
    for post_id in 1..=(size * 3) as i64 {
        for tag_id in 1..=3 {
            tx.execute(
                "INSERT INTO post_tags (post_id, tag_id) VALUES (?1, ?2)",
                params![post_id, tag_id],
            )?;
        }
    }
    tx.commit()?;

    // =====================
    // SELECT + UPDATE
    // =====================
    let users_vec: Vec<(i64, String)> = {
        let mut stmt = conn.prepare("SELECT id, username FROM users")?;
        let user_iter = stmt.query_map([], |row| {
            Ok((row.get::<_, i64>(0)?, row.get::<_, String>(1)?))
        })?;

        user_iter.collect::<Result<Vec<_>, _>>()?
    };

    let tx = conn.transaction()?;

    for (id, username) in users_vec {
        let new_username = format!("{}-updated", username);
        tx.execute(
            "UPDATE users SET username=?1 WHERE id=?2",
            [new_username, id.to_string()],
        )?;
        checksum = checksum.wrapping_add(id as u64);
    }
    tx.commit()?;

    // =====================
    // DELETE some COMMENTS
    // =====================
    conn.execute("DELETE FROM comments WHERE id % 2 = 0", [])?;

    Ok(checksum)
}
