USE enricher;

-- Find the track(s) with the highest play count for each album.
SELECT 
    t.track_id,
    t.title AS track_title,
    a.title AS album_title,
    t.play_count
FROM Tracks t
JOIN Albums a ON t.album_id = a.album_id
WHERE t.play_count = (
    SELECT MAX(t2.play_count)
    FROM Tracks t2
    WHERE t2.album_id = t.album_id
);