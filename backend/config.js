const Database = require("better-sqlite3");
const path = require("path");
const fs = require("fs");

const dbPath = process.env.DB_PATH || path.join(__dirname, "game_collection.db");
fs.mkdirSync(path.dirname(dbPath), { recursive: true });

const db = new Database(dbPath);
db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

// First run: create tables from schema.sql
if (!db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'").get()) {
    db.exec(fs.readFileSync(path.join(__dirname, "schema.sql"), "utf8"));
}

// Mimics mysql2's query(sql, params, cb) so routes need few changes
function query(sql, params, cb) {
    if (typeof params === "function") { cb = params; params = []; }
    try {
        const stmt = db.prepare(sql);
        if (stmt.reader) return cb(null, stmt.all(params));
        const info = stmt.run(params);
        cb(null, { affectedRows: info.changes, insertId: info.lastInsertRowid });
    } catch (err) {
        cb(err);
    }
}

module.exports = { query, end: (cb) => { db.close(); cb && cb(); } };