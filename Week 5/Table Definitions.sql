USE enricher;

CREATE TABLE Artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE Albums (
    album_id INT PRIMARY KEY,
    title VARCHAR(100),
    release_date DATE,
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

CREATE TABLE Tracks (
    track_id INT PRIMARY KEY,
    title VARCHAR(100),
    duration_seconds INT,
    album_id INT,
    play_count INT,
    FOREIGN KEY (album_id) REFERENCES Albums(album_id)
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100),
    registration_date DATE
);

CREATE TABLE Playlists (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(100),
    created_by INT,
    creation_date DATE,
    FOREIGN KEY (created_by) REFERENCES Users(user_id)
);

CREATE TABLE PlaylistTracks (
    playlist_id INT,
    track_id INT,
    position INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),
    FOREIGN KEY (track_id) REFERENCES Tracks(track_id)
);
