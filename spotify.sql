SELECT * FROM spotify;

-------------
-- Easy Level
-------------
-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track
FROM spotify
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.

SELECT DISTINCT Album, Artist
FROM spotify;

-- 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) AS Total_Comments
FROM spotify
WHERE licensed = TRUE;

-- 4. Find all tracks that belong to the album type single.

SELECT Track
FROM spotify
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.

SELECT Artist, COUNT(track) AS Total_Tracks
FROM spotify
GROUP BY artist
ORDER BY 2 DESC;

---------------
-- Medium Level
---------------

-- 6. Calculate the average danceability of tracks in each album.

SELECT Album, AVG(danceability) AS Average_DanceAbility
FROM spotify
GROUP BY album
ORDER BY 2 DESC;

-- 7. Find the top 5 tracks with the highest energy values.

SELECT Track, MAX(Energy) AS Energy
FROM spotify
GROUP BY track
ORDER BY Energy DESC
LIMIT 5; 

-- 8. List all tracks along with their views and likes where official_video = TRUE.

SELECT Track,
	SUM(Views) AS Total_Views,
    SUM(Likes) AS Total_Likes
FROM spotify
WHERE official_video = TRUE
GROUP BY 1
ORDER BY 2 DESC;

-- 9. For each album, calculate the total views of all associated tracks.

SELECT Album, Track, SUM(views) AS Total_Views
FROM spotify
GROUP BY album, track
ORDER BY 3 DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT 
	Track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube
FROM spotify
GROUP BY track) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0;

-- Advanced Level
-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking AS
(SELECT artist, track, SUM(views) AS total_views,
DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rnk
FROM spotify
GROUP BY 1,2)
SELECT Artist, Track, total_views
FROM ranking
WHERE rnk <=3;

-- 12. Write a query to find tracks where the liveness score is above the average.


SELECT Track, Liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH max AS
(SELECT album, MAX(energy) AS Highest
FROM spotify
GROUP BY album),
min AS
(SELECT album, MIN(energy) AS Lowest
FROM spotify
GROUP BY album)
SELECT max.album, Highest, Lowest, Highest - Lowest AS Difference
FROM max
JOIN min ON max.album = min.album
ORDER BY 4 DESC;

WITh min_max AS(
SELECT Album, MAX(energy) AS Highest, MIN(energy) AS Lowest
FROM spotify
GROUP BY album)
SELECT *, Highest - Lowest AS Difference
FROM min_max
ORDER BY 4 DESC;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT Track
FROM spotify
WHERE energy_liveness > 1.2;

SELECT Track, Energy, Liveness, Energy/Liveness
FROM spotify
WHERE Energy/Liveness > 1.2;


-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT Track, SUM(Views) AS total_views, SUM(Likes) AS total_likes,
SUM(SUM(likes)) OVER(ORDER BY SUM(views) DESC) AS Cumulative_likes
FROM spotify
GROUP BY Track;