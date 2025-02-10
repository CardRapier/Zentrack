-- +goose Up
-- +goose StatementBegin
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL,
    password VARCHAR NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_people (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    relation VARCHAR
);

CREATE TABLE user_books (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    current_page INTEGER NOT NULL,
    pages INTEGER NOT NULL,
    finished BOOLEAN NOT NULL
);

CREATE TABLE event_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    icon VARCHAR NOT NULL
);

CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    event_type_id INTEGER NOT NULL REFERENCES event_types(id),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_people_id INTEGER REFERENCES user_people(id) ON DELETE CASCADE,
    details JSONB NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE habit_types(
    id SERIAL PRIMARY KEY,
    type VARCHAR NOT NULL
);

CREATE TABLE habits (
    id SERIAL PRIMARY KEY,
    type_id INTEGER NOT NULL REFERENCES habit_types(id),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    frequency INTEGER,
    frequency_type VARCHAR,
    color VARCHAR NOT NULL,
    icon VARCHAR NOT NULL,
    min_frequency INTEGER,
    notify_at TIME WITH TIMEZONE
);


CREATE TABLE habit_tracks (
    id SERIAL PRIMARY KEY,
    habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    done_at TIMESTAMPTZ NOT NULL,
    is_valid BOOLEAN DEFAULT TRUE,
    details JSONB NOT NULL
);

-- Creating HYPERTABLES
SELECT create_hypertable('events', 'occurred_at');
SELECT create_hypertable('habit_tracks', 'done_at');

-- Indexing
CREATE UNIQUE INDEX users_email_unique ON users (email);

CREATE INDEX user_people_user_idx ON user_people (user_id);

CREATE INDEX user_books_user_idx ON user_books (user_id);

CREATE INDEX events_time_idx ON events (occurred_at DESC);
CREATE INDEX events_type_user_idx ON events (user_id);
CREATE INDEX events_type_user_user_people_idx ON events (user_id, user_people_id);
CREATE INDEX events_type_user_event_type_idx ON events (user_id, event_type_id);
CREATE INDEX events_details_idx ON events USING GIN (details);

CREATE INDEX habit_user_idx ON habits (user_id);

CREATE INDEX habit_tracks_time_idx ON habit_tracks (done_at DESC);
CREATE INDEX habit_tracks_type_user_idx ON habit_tracks (habit_id);
CREATE INDEX habit_tracks_details_idx ON habit_tracks USING GIN (details);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS user_people CASCADE;
DROP TABLE IF EXISTS user_books CASCADE;
DROP TABLE IF EXISTS event_types CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS habit_types CASCADE;
DROP TABLE IF EXISTS habits CASCADE;
DROP TABLE IF EXISTS habit_tracks CASCADE;
-- +goose StatementEnd
