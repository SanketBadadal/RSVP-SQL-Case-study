USE imdb; 

-- Segment 1:
-- Q1. Find the total number of rows in each table of the schema?
SELECT Count(*) AS TABLE_ROWS
FROM   director_mapping;

SELECT Count(*) AS TABLE_ROWS
FROM   genre;

SELECT Count(*) AS TABLE_ROWS
FROM   movie;

SELECT Count(*) AS TABLE_ROWS
FROM   names;

SELECT Count(*) AS TABLE_ROWS
FROM   ratings;

SELECT Count(*) AS TABLE_ROWS
FROM   role_mapping; 

-- Below can be the alternative approach for calculating number of rows 
SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';

-- Q2. Which columns in the movie table have null values?

-- Below query is calculating the null values count in particular column 
SELECT Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS title_nulls,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS year_nulls,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS date_published_nulls,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS duration_nulls,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS country_nulls,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS worlwide_gross_income_nulls,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS languages_nulls,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS production_company_nulls
FROM   movie; 

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */


SELECT year,
       Count(id) AS number_of_movies
FROM   movie
GROUP  BY year
ORDER  BY year; 

-- Number of movies released each month.

SELECT Month(date_published) AS month_num,
       Count(id)             AS number_of_movies
FROM   movie
GROUP  BY Month(date_published)
ORDER  BY Month(date_published); 


-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT Count(id) AS number_of_movies,year
FROM   movie
WHERE  year = 2019
       AND (country LIKE '%USA%' OR country LIKE '%India%' );


-- Q5. Find the unique list of the genres present in the data set?


SELECT DISTINCT genre
FROM   genre; 


-- Q6.Which genre had the highest number of movies produced overall?


SELECT genre,
       year,
       COUNT(movie_id) AS number_of_movies
FROM   genre AS A
       INNER JOIN movie AS B
               ON A.movie_id = B.id
WHERE  year = 2019
GROUP  BY genre
ORDER  BY number_of_movies DESC
LIMIT  1; 


-- Q7. How many movies belong to only one genre?

SELECT Sum(number_of_movies) AS number_of_movies
FROM   (SELECT Count(genre) AS number_of_movies
        FROM   genre
        GROUP  BY movie_id
        HAVING Count(genre) = 1) AS A; 


-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT genre,
       Round(Avg(duration), 2) AS avg_duration
FROM   genre AS A
       INNER JOIN movie AS B
               ON A.movie_id = B.id
GROUP  BY genre
ORDER  BY avg_duration DESC; 

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/

WITH genre_wise_rank
     AS (SELECT genre,
                Count(movie_id)                    AS movie_count,
                RANK()
                  OVER (
                    ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre
         ORDER  BY movie_count DESC)
SELECT *
FROM   genre_wise_rank
WHERE  genre = 'Thriller'; 


-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings; 


-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

WITH title_wise_rank
     AS (SELECT title,
                avg_rating,
                RANK()
                  OVER(
                    ORDER BY avg_rating DESC) AS movie_rank
         FROM   movie AS A
                INNER JOIN ratings AS B
                        ON A.id = B.movie_id
         ORDER  BY avg_rating DESC)
SELECT *
FROM   title_wise_rank
WHERE  movie_rank <= 10; 


WITH title_wise_rank
     AS (SELECT title,
                avg_rating,
                DENSE_RANK()
                  OVER(
                    ORDER BY avg_rating DESC) AS movie_rank
         FROM   movie AS A
                INNER JOIN ratings AS B
                        ON A.id = B.movie_id
         ORDER  BY avg_rating DESC)
SELECT *
FROM   title_wise_rank
WHERE  movie_rank <= 10; 


-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/

WITH prod_company_wise_rank
     AS (SELECT production_company,
                Count(id)                    AS movie_count,
                RANK()
                  OVER (
                    ORDER BY Count(id) DESC) AS prod_company_rank
         FROM   movie AS A
                INNER JOIN ratings AS B
                        ON A.id = B.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company
         ORDER  BY movie_count DESC)
SELECT *
FROM   prod_company_wise_rank
WHERE  prod_company_rank = 1; 

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */


SELECT A.genre,
       Count(A.movie_id) AS movie_count
FROM   genre AS A
       INNER JOIN ratings AS B using (movie_id)
       INNER JOIN movie AS C
               ON A.movie_id = C.id
WHERE  LEFT(C.date_published, 7) = '2017-03'
       AND C.country = 'USA'
       AND B.total_votes > 1000
GROUP  BY A.genre
ORDER  BY movie_count DESC; 


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT A.title,
       B.avg_rating,
       C.genre
FROM   movie AS A
       INNER JOIN ratings AS B
               ON A.id = B.movie_id
       INNER JOIN genre AS C
               ON A.id = C.movie_id
WHERE  A.title LIKE 'THE%'
       AND B.avg_rating > 8
ORDER BY avg_rating DESC; 

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT A.median_rating,
       Count(A.movie_id) AS movie_count
FROM   ratings AS A
       INNER JOIN movie AS B
               ON A.movie_id = B.id
WHERE  B.date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND A.median_rating = 8
GROUP  BY A.median_rating
ORDER  BY movie_count; 


-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.


SELECT A.languages,
       B.total_votes AS total_number_of_votes
FROM   movie AS A
       INNER JOIN ratings AS B
               ON A.id = B.movie_id
WHERE languages LIKE 'German' OR languages LIKE 'Italian'
GROUP  BY A.languages
ORDER  BY total_number_of_votes DESC; 


-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT Sum(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls
FROM   names; 


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */


WITH director_wise_rank
     AS (SELECT E.NAME                               AS director_name,
                Count(D.movie_id)                    AS movie_count,
                ROW_NUMBER()
                  OVER (
                    ORDER BY Count(D.movie_id) DESC) AS director_rank
         FROM   director_mapping AS D
                INNER JOIN names AS E
                        ON D.name_id = E.id
                INNER JOIN genre AS F using (movie_id)
                INNER JOIN ratings AS G using (movie_id)
         WHERE  G.avg_rating > 8
                AND F.genre IN (SELECT genre
                                FROM   (WITH genre_wise_rank
                                             AS (SELECT A.genre,
                                                        Count(A.movie_id)
                                                        AS
                                                        movie_count,
                                                        RANK()
                                                          OVER (
                                                            ORDER BY
                                                          Count(A.movie_id)
                                                          DESC) AS
                                                        genre_rank
                                                 FROM   genre AS A
                                                        INNER JOIN ratings AS B
                                                        using
                                                        (
                                                        movie_id)
                                                 WHERE  B.avg_rating > 8
                                                 GROUP  BY A.genre
                                                 ORDER  BY movie_count DESC)
                                        SELECT *
                                         FROM   genre_wise_rank
                                         WHERE  genre_rank <= 3) AS C)
         GROUP  BY E.NAME
         ORDER  BY movie_count DESC)
SELECT director_name,
       movie_count
FROM   director_wise_rank
WHERE  director_rank <= 3; 


-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */


WITH actor_wise_rank
     AS (SELECT A.NAME                                        AS actor_name,
                Count(DISTINCT C.movie_id)                    AS movie_count,
                ROW_NUMBER()
                  OVER (
                    ORDER BY Count(DISTINCT C.movie_id) DESC) AS actor_rank
         FROM   names AS A
                INNER JOIN role_mapping AS B
                        ON A.id = B.name_id
                INNER JOIN ratings AS C
                        ON B.movie_id = C.movie_id
         WHERE  C.median_rating >= 8
                AND B.category = 'actor'
         GROUP  BY A.NAME
         ORDER  BY movie_count DESC)
SELECT actor_name,
       movie_count
FROM   actor_wise_rank
WHERE  actor_rank <= 2; 


-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

WITH prod_wise_rank
     AS (SELECT A.production_company,
                Sum(B.total_votes)                    AS vote_count,
                DENSE_RANK()
                  OVER (
                    ORDER BY Sum(B.total_votes) DESC) AS prod_comp_rank
         FROM   movie AS A
                INNER JOIN ratings AS B
                        ON A.id = B.movie_id
         GROUP  BY A.production_company
         ORDER  BY vote_count DESC)
SELECT *
FROM   prod_wise_rank
WHERE  prod_comp_rank <= 3; 

/*Yes Marvel Studios rules the movie world.

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actor_wise_rank
     AS (SELECT C.NAME
                AS
                   actor_name,
                A.total_votes
                   AS total_votes,
                Count(A.movie_id)
                   AS movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2)
                   AS actor_avg_rating,
                RANK()
                  OVER (
                    partition BY B.category = 'actor'
                    ORDER BY A.avg_rating DESC, A.total_votes
                  DESC, Count(A.movie_id)
                  DESC) AS
                actor_rank
         FROM   ratings AS A
                INNER JOIN role_mapping AS B using (movie_id)
                INNER JOIN names AS C
                        ON B.name_id = C.id
                INNER JOIN movie AS D
                        ON A.movie_id = D.id
         WHERE  D.country = 'India'
                AND B.category = 'actor'
         GROUP  BY C.NAME
         HAVING Count(A.movie_id) >= 5
         ORDER  BY actor_avg_rating DESC,
                   total_votes DESC,
                   movie_count DESC)
SELECT *
FROM   actor_wise_rank
WHERE  actor_rank = 1; 

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/


WITH actress_wise_rank
     AS (SELECT C.NAME
                AS
                   actress_name,
                A.total_votes
                   AS total_votes,
                Count(A.movie_id)
                   AS movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2)
                   AS actress_avg_rating,
                RANK()
                  OVER (
                    partition BY B.category = 'actress'
                    ORDER BY ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS
                actress_rank
         FROM   ratings AS A
                INNER JOIN role_mapping AS B using (movie_id)
                INNER JOIN names AS C
                        ON B.name_id = C.id
                INNER JOIN movie AS D
                        ON A.movie_id = D.id
         WHERE  D.country = 'India'
                AND B.category = 'actress'
                AND D.languages LIKE '%Hindi%'
         GROUP  BY C.NAME
         HAVING Count(A.movie_id) >= 3
         ORDER  BY actress_avg_rating DESC,
                   total_votes DESC,
                   movie_count DESC)
SELECT *
FROM   actress_wise_rank
WHERE  actress_rank <= 5; 

/* Taapsee Pannu tops with average rating 7.74. 


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT title,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN avg_rating < 5 THEN 'Flop movies'
       END AS avg_rating_category
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  genre = 'thriller'; 

	
-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

WITH genre_wise_avg_duration AS
(
           SELECT     genre,
                      Round(Avg(duration),2) AS avg_duration
           FROM       genre                  AS a
           INNER JOIN movie                  AS b
           ON         a.movie_id = b.id
           GROUP BY   genre )
SELECT   *,
         sum(avg_duration) OVER w          AS running_total_duration,
         round(avg(avg_duration) OVER w,2) AS moving_avg_duration
FROM     genre_wise_avg_duration window w  AS (ORDER BY avg_duration rows UNBOUNDED PRECEDING);


-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH movie_rank
     AS (SELECT genre,
                year,
                title,
                worlwide_gross_income,
                DENSE_RANK()
                  OVER (
                    partition BY year
                    ORDER BY worlwide_gross_income DESC) AS movie_rank
         FROM   movie AS A
                INNER JOIN genre AS B
                        ON A.id = B.movie_id
         WHERE  genre IN
                -- Top 3 Genres based on most number of movies
                (SELECT genre
                 FROM   (SELECT genre,
                                Count(movie_id)                    AS
                                movie_count,
                                RANK ()
                                  OVER (
                                    ORDER BY Count(movie_id) DESC) AS genre_rank
                         FROM   genre
                         GROUP  BY genre) AS C
                 WHERE  genre_rank <= 3)
         ORDER  BY genre,
                   year,
                   worlwide_gross_income DESC)
SELECT *
FROM   movie_rank
WHERE  movie_rank <= 5
ORDER  BY year,
          movie_rank,
          genre; 


-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/


WITH production_wise_rank
     AS (SELECT production_company,
                COUNT(id)                    AS movie_count,
                DENSE_RANK()
                  over (
                    ORDER BY COUNT(id) DESC) AS prod_comp_rank
         FROM   movie AS A
                inner join ratings AS B
                        ON A.id = B.movie_id
         WHERE  median_rating >= 8
                AND POSITION(',' IN languages) > 0
                AND production_company IS NOT NULL
         GROUP  BY production_company
         ORDER  BY movie_count DESC)
SELECT *
FROM   production_wise_rank
WHERE  prod_comp_rank <= 2; 

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_rank
     AS (SELECT C.NAME                               AS actress_name,
                Sum(A.total_votes)                   AS total_votes,
                Count(A.movie_id)                    AS movie_count,
                A.avg_rating                         AS actress_avg_rating,
                DENSE_RANK()
                  OVER (
                    partition BY category = 'actress'
                    ORDER BY avg_rating DESC) AS actress_rank
         FROM   ratings AS A
                INNER JOIN role_mapping AS B using (movie_id)
                INNER JOIN names AS C
                        ON B.name_id = C.id
                INNER JOIN genre AS D
                        ON A.movie_id = D.movie_id
         WHERE  category = 'actress'
                AND genre = 'Drama'
                AND avg_rating > 8
         GROUP  BY C.NAME)
SELECT *
FROM   actress_rank
WHERE  actress_rank <= 3
ORDER  BY actress_rank,
          total_votes DESC,
          actress_avg_rating DESC
LIMIT 3; 

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/


WITH director_rank
     AS (SELECT name_id                            AS director_id,
                NAME                               AS director_name,
                Count(movie_id)                    AS number_of_movies,
                Round(Avg(inter_movie_days), 2)    AS avg_inter_movie_days,
                Round(Avg(avg_rating), 2)          AS avg_rating,
                Sum(total_votes)                   AS total_votes,
                Min(avg_rating)                    AS min_rating,
                Max(avg_rating)                    AS max_rating,
                Sum(duration)                      AS total_duration,
                ROW_NUMBER()
                  OVER (
                    ORDER BY Count(movie_id) DESC) AS Director_rank
         FROM   (WITH inter_movie_days
                      AS (SELECT A.name_id                    AS name_id,
                                 B.NAME                       AS NAME,
                                 A.movie_id                   AS movie_id,
                                 C.avg_rating                 AS avg_rating,
                                 C.total_votes                AS total_votes,
                                 D.duration                   AS duration,
                                 D.date_published             AS date_published,
                                 LEAD(D.date_published, 1, "")
                                   OVER (
                                     partition BY A.name_id
                                     ORDER BY date_published, A.movie_id ) AS
                                 next_date_published
                          FROM   director_mapping AS A
                                 INNER JOIN names AS B
                                         ON A.name_id = B.id
                                 INNER JOIN ratings AS C
                                         ON A.movie_id = C.movie_id
                                 INNER JOIN movie AS D
                                         ON A.movie_id = D.id
                          ORDER  BY A.name_id,
                                    date_published)
                 SELECT *,
                        COALESCE(Datediff(next_date_published, date_published),
                        0) AS
                        inter_movie_days
                  FROM   inter_movie_days) AS Z
         GROUP  BY 1,
                   2
         ORDER  BY number_of_movies DESC)
SELECT director_id,
       director_name,
       number_of_movies,
       avg_inter_movie_days,
       avg_rating,
       total_votes,
       min_rating,
       max_rating,
       total_duration
FROM   director_rank
WHERE  director_rank <= 9
ORDER  BY number_of_movies DESC,
          director_name; 

             





