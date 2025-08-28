USE enricher;

SELECT *
FROM PlaylistTracks;

SELECT *
FROM Tracks;

WITH playlist_totals AS (
  SELECT pt.playlist_id, SUM(t.duration_seconds) AS total_seconds
  FROM PlaylistTracks pt
  JOIN Tracks t ON t.track_id = pt.track_id
  GROUP BY pt.playlist_id
)
SELECT p.playlist_id, p.name,
       COALESCE(pt.total_seconds,0) AS total_seconds,
       SEC_TO_TIME(COALESCE(pt.total_seconds,0)) AS hh_mm_ss
FROM Playlists p
LEFT JOIN playlist_totals pt ON pt.playlist_id = p.playlist_id
ORDER BY total_seconds DESC;

SELECT p.playlist_id, p.name,
       COALESCE(SUM(t.duration_seconds), 0) AS total_seconds,
       SEC_TO_TIME(COALESCE(SUM(t.duration_seconds), 0)) AS hh_mm_ss
FROM Playlists p
LEFT JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
LEFT JOIN Tracks t ON pt.track_id = t.track_id
GROUP BY p.playlist_id, p.name
ORDER BY total_seconds DESC;

WITH artist_uses AS (
  SELECT a.artist_id, a.name, COUNT(*) AS appearances
  FROM PlaylistTracks pt
  JOIN Tracks t ON t.track_id = pt.track_id
  JOIN Albums al ON al.album_id = t.album_id
  JOIN Artists a ON a.artist_id = al.artist_id
  GROUP BY a.artist_id, a.name
)
SELECT * FROM artist_uses ORDER BY appearances DESC, name;

SELECT * FROM playlist_stats;

SELECT p.playlist_id,
       p.name,
       COALESCE(SUM(t.duration_seconds), 0) AS total_seconds
FROM Playlists p
LEFT JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
LEFT JOIN Tracks t ON pt.track_id = t.track_id
GROUP BY p.playlist_id, p.name;

SELECT al.title AS album, al.release_date,
       DATE_ADD(CURDATE(), INTERVAL 7 DAY) AS next_week,
       CASE WHEN al.release_date < DATE_SUB(CURDATE(), INTERVAL 10 YEAR)
            THEN 'Classic' ELSE 'Recent' END AS era
FROM Albums al;

SELECT UPPER(title) AS cap_title, title
FROM Tracks;

SELECT CONCAT(a.name, ' — ', t.title) AS name_title, a.name, t.title
FROM Tracks t
JOIN Albums al ON al.album_id = t.album_id
JOIN Artists a ON a.artist_id = al.artist_id;

SELECT title, ROUND(duration_seconds / 60, 2) AS minutes, duration_seconds / 60
FROM Tracks;


DECLARE v_playlist_id INT;


DELIMITER //
-- Changes delimiter from ; to //

CREATE TRIGGER trg_playlists_after_update
AFTER UPDATE ON Playlists
FOR EACH ROW
BEGIN
  INSERT INTO AuditLog (action, table_name, row_ref, details)
  VALUES (
    'UPDATE', 'Playlists',
    CONCAT('playlist_id=', NEW.playlist_id),
    JSON_OBJECT(
      'old_name', OLD.name, 'new_name', NEW.name,
      'old_user', OLD.created_by, 'new_user', NEW.created_by,
      'ts', NOW()
    )
  );
END //

SELECT *
FROM AuditLog;

SELECT * FROM PlaylistStats ORDER BY total_seconds DESC;

INSERT INTO PlaylistTracks (playlist_id, track_id, position) VALUES (1,2,2);


SELECT * FROM AuditLog ORDER BY action_time DESC LIMIT 10;

INSERT INTO PlaylistTracks (playlist_id, track_id, position) VALUES (5,1,3);

DELETE FROM PlaylistTracks WHERE playlist_id=1 AND track_id=2;

UPDATE Playlists SET name = 'Alice Favorites (Renamed)' WHERE playlist_id = 1;












DELIMITER //

CREATE PROCEDURE refresh_playlist_stats_cursor()
BEGIN
  DECLARE v_playlist_id BIGINT;
  DECLARE v_total_ms BIGINT;
  DECLARE done INT DEFAULT 0;

  -- Cursor returns each playlist and its total ms
  DECLARE cur CURSOR FOR
    SELECT p.playlist_id, IFNULL(SUM(s.duration_ms),0) AS total_ms
    FROM Playlists p
    LEFT JOIN playlist_song ps ON ps.playlist_id = p.playlist_id
    LEFT JOIN songs s ON s.song_id = ps.song_id
    GROUP BY p.playlist_id;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_playlist_id, v_total_ms;
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    -- Upsert summary row
    INSERT INTO playlist_stats (playlist_id, total_ms, last_refreshed)
    VALUES (v_playlist_id, v_total_ms, NOW())
    ON DUPLICATE KEY UPDATE total_ms = VALUES(total_ms), last_refreshed = NOW();
  END LOOP;

  CLOSE cur;

  SELECT * FROM playlist_stats ORDER BY total_ms DESC;
END //


DELIMITER ;

-- Run it:
CALL refresh_playlist_stats_cursor();

DROP PROCEDURE IF EXISTS refresh_playlist_stats_cursor;


DROP TABLE IF EXISTS PlaylistStats;
CREATE TABLE PlaylistStats (
  playlist_id    INT PRIMARY KEY,
  total_seconds  BIGINT NOT NULL,
  last_refreshed TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_stats_playlist FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

DELIMITER //

CREATE PROCEDURE refresh_playlist_stats_cursor()
BEGIN
  DECLARE v_playlist_id INT;
  DECLARE v_total_seconds BIGINT;
  DECLARE done INT DEFAULT 0;

  -- Cursor: one row per playlist with summed seconds
  DECLARE cur CURSOR FOR
    SELECT p.playlist_id,
           COALESCE(SUM(t.duration_seconds), 0) AS total_seconds
    FROM Playlists p
    LEFT JOIN PlaylistTracks pt ON pt.playlist_id = p.playlist_id
    LEFT JOIN Tracks t ON t.track_id = pt.track_id
    GROUP BY p.playlist_id;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_playlist_id, v_total_seconds;
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    -- Upsert summary row
    INSERT INTO PlaylistStats (playlist_id, total_seconds, last_refreshed)
    VALUES (v_playlist_id, v_total_seconds, NOW())
    ON DUPLICATE KEY UPDATE
      total_seconds  = VALUES(total_seconds),
      last_refreshed = NOW();
  END LOOP;

  CLOSE cur;

END //

DELIMITER ;

CALL refresh_playlist_stats_cursor();





DELIMITER //

CREATE PROCEDURE add_track_to_playlist(
  IN p_playlist_id INT,
  IN p_track_id INT,
  IN p_position INT
)
BEGIN
  -- This modifies data (INSERT into PlaylistTracks)
  INSERT INTO PlaylistTracks (playlist_id, track_id, position)
  VALUES (p_playlist_id, p_track_id, p_position);

  -- Optionally update play_count in Tracks (also a modification)
  UPDATE Tracks
  SET play_count = play_count + 1
  WHERE track_id = p_track_id;
END //

DELIMITER ;

-- Call it:
CALL add_track_to_playlist(4, 3, 1);

SELECT *
FROM Tracks;

SELECT *
FROM PlaylistTracks;

