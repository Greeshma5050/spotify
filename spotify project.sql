/*DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);*/
select * from spotify

--EASY

--Q1.Retrieve the names of all tracks that have more than 1 billion streams;
select track from spotify where stream>1000000000

--Q2.list all albums along with their respective artists;
select album,artist from spotify 

--Q3.get the total number of comments for tracks where licensed = True;
select sum(comments) as comments_sum from spotify where licensed = True

--Q4.find all tracks that belong to the album type single.
SELECT TRACK,album_type FROM SPOTIFY WHERE ALBUM_type= 'single'

--Q5.count the total number of tracks by each artist.
select artist,count(track) from spotify group by artist

--Medium

--Q1.Calculate the average danceability of tracks in each album.
select album,avg(danceability) from spotify group by album

--Q2.find the top 5 tracks with the highest energy values.
select track,energy from spotify group by track order by energy desc limit 5;

--Q3.list all tracks along their views and likes where official_video = TRUE.
select track,sum(views) as total_views,sum(likes) as total_likes from spotify 
where official_video = True group by track order by total_views desc;

--Q4.for each album,calculate the total views of all associated tracks.
select album,sum(views) as total_views,track from spotify group by album, track

--Q5.retrieve the track names that have been streamed on spotify more than youtube
select track,streamed_on_spotify,streamed_on_Youtube,
case 
when streamed_on_spotify > streamed_on_Youtube then 'spotify'
when streamed_on_youtube > streamed_on_spotify then 'Youtube'
else 'Tie'
end as most_played_platform from
(select track,
coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify,
coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_Youtube
from spotify
group by track) as t1
where streamed_on_Youtube<>0 
and
streamed_on_spotify > streamed_on_youtube
order by most_played_platform


--Hard

--Q1.Find the top 3 most-viewed tracks for each artist using window functions
with cte as(
Select track,artist,
dense_rank() over(partition by artist order by views desc) as rank
from spotify
)
select * from cte where rank <= 3

--Q2.Write a query to find the tracks where the liveness score is above the average
select track from spotify where liveness > (select avg(liveness) as avg_liveness from spotify)

--Q3.Use a with clause to calculate the difference between the highest and lowest energy values for tracks in each album
with cte as(
select album,
max(energy) as highest, 
min(energy) as lowest
from spotify
group by album
)
select album,
highest-lowest as energy_diff 
from cte
order by energy_diff desc


--Q4.Find tracks where the energy-to-liveness ratio is greater than 1.2
select track,
energy,
liveness,
energy/nullif(liveness,0) as ratio
from spotify
where liveness is not null
and energy is not null
and energy/nullif(liveness,0) > 1.2

--Q5.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select track,likes,views,
sum(likes) over(order by views desc rows between unbounded preceding and current row) as cum_likes
from spotify

