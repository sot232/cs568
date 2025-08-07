USE enricher;

-- Artists
INSERT INTO Artists VALUES
(1, 'The Beatles', 'Rock'),
(2, 'Adele', 'Pop'),
(3, 'Drake', 'Hip-Hop');

-- Albums
INSERT INTO Albums VALUES
(1, 'Abbey Road', '1969-09-26', 1),
(2, '25', '2015-11-20', 2),
(3, 'Scorpion', '2018-06-29', 3);

-- Tracks
INSERT INTO Tracks VALUES
(1, 'Come Together', 259, 1, 500000),
(2, 'Hello', 295, 2, 750000),
(3, 'God\'s Plan', 198, 3, 900000);

-- Users
INSERT INTO Users VALUES
(1, 'johndoe', 'john@example.com', '2020-01-15'),
(2, 'janedoe', 'jane@example.com', '2021-06-30');

-- Playlists
INSERT INTO Playlists VALUES
(1, 'Rock Classics', 1, '2020-02-01'),
(2, 'Top Pop Hits', 2, '2021-07-01');

-- PlaylistTracks
INSERT INTO PlaylistTracks VALUES
(1, 1, 1),
(2, 2, 1),
(2, 3, 2);
