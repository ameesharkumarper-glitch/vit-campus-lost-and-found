
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    reg_no        TEXT NOT NULL UNIQUE,
    email         TEXT NOT NULL UNIQUE,
    phone         TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    alias         TEXT NOT NULL UNIQUE,          -- the ONLY identity ever shown to other students
    created_at    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS items (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    kind                  TEXT NOT NULL CHECK (kind IN ('lost','found')),
    title                 TEXT NOT NULL,
    description           TEXT NOT NULL,
    category              TEXT NOT NULL,
    venue                 TEXT NOT NULL,
    verification_question TEXT NOT NULL,
    owner_id              INTEGER NOT NULL REFERENCES users(id),   -- the poster (finder or loser)
    status                TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','resolved')),
    created_at            TEXT NOT NULL,
    resolved_at           TEXT,
    resolved_by           INTEGER REFERENCES users(id)
);
CREATE INDEX IF NOT EXISTS idx_items_feed ON items(status, kind, created_at DESC);

CREATE TABLE IF NOT EXISTS claims (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    item_id              INTEGER NOT NULL REFERENCES items(id),
    claimant_id          INTEGER NOT NULL REFERENCES users(id),
    answer               TEXT NOT NULL,
    status               TEXT NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','approved','rejected','closed')),
    checkpoint           TEXT,
    checkpoint_by        INTEGER REFERENCES users(id),
    checkpoint_confirmed INTEGER NOT NULL DEFAULT 0,
    created_at           TEXT NOT NULL,
    decided_at           TEXT,
    UNIQUE (item_id, claimant_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    claim_id   INTEGER NOT NULL REFERENCES claims(id),
    sender_id  INTEGER REFERENCES users(id),     -- NULL = system message
    body       TEXT NOT NULL,
    created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_messages_claim ON messages(claim_id, id);
