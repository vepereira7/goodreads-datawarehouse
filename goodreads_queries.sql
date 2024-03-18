-- Q1 - Top 10 tags que mais aparecem no To_Read --

SELECT DISTINCT R.book_id, B.original_title, T.count, Tag.tag_name
FROM to_read R
JOIN book_tags T ON R.book_id = T.book_id
JOIN tags Tag ON T.tag_id = Tag.tag_id
JOIN books B ON B.book_id = R.book_id
ORDER BY T.count DESC
LIMIT 10
---------------

-- Q2 - O livro com maior rating por década/ século / --
-- This query allows to give an input and select the year
book.original_title,book.original_title, stat.avg_rating, stat.year
FROM books book
JOIN statistics_rating stat ON book.book_id=stat.book_id
WHERE stat.year = 2010
ORDER BY stat.avg_rating DESC
LIMIT 1

-- This query retrives the best book from 2010-2019
SELECT book.original_title, stat.avg_rating, stat.year
FROM books book
JOIN statistics_rating stat ON book.book_id=stat.book_id
WHERE stat.year BETWEEN 2010 AND 2019
ORDER BY stat.avg_rating DESC
LIMIT 1

-- This query retrives the best rated book per year since 2010
SELECT original_title,title, avg_rating, year
FROM (
  SELECT book.original_title, book.title, stat.avg_rating, stat.year, 
         ROW_NUMBER() OVER (PARTITION BY stat.year ORDER BY stat.avg_rating DESC) AS rank
  FROM books book
  JOIN statistics_rating stat ON book.book_id = stat.book_id
  WHERE stat.year BETWEEN 2010 AND 2019
) ranked
WHERE rank = 1
ORDER BY year ASC
-----------------

-- Q3 - Evolução da atribuição das tags ao longo dos últimos 10/20 anos --
-- This query allows to give an input and select the year
SELECT tag.tag_name, bt.count, stat.avg_rating, stat.year
FROM tags tag
JOIN book_tags bt ON bt.tag_id = tag.tag_id
JOIN statistics_rating stat ON stat.book_id = bt.book_id
WHERE stat.year = 2010
ORDER BY bt.count DESC
LIMIT 1

-- This query retrieves the most added tag per year since 2010
SELECT tag_name, count, avg_rating, year
FROM (
  SELECT tag.tag_name, bt.count, stat.avg_rating, stat.year,
         ROW_NUMBER() OVER (PARTITION BY stat.year ORDER BY bt.count DESC) AS rank
  FROM tags tag
  JOIN book_tags bt ON bt.tag_id = tag.tag_id
  JOIN statistics_rating stat ON stat.book_id = bt.book_id
  WHERE stat.year BETWEEN 2010 AND 2019
) ranked
WHERE rank = 1
ORDER BY year ASC

-- This query retrieves the 21st most added tag per year since 2010
SELECT DISTINCT tag_name, count, avg_rating, year
FROM (
  SELECT tag.tag_name, bt.count, stat.avg_rating, stat.year,
         ROW_NUMBER() OVER (PARTITION BY stat.year ORDER BY bt.count DESC) AS rank
  FROM tags tag
  JOIN book_tags bt ON bt.tag_id = tag.tag_id
  JOIN statistics_rating stat ON stat.book_id = bt.book_id
  WHERE stat.year BETWEEN 2010 AND 2019 AND tag.tag_name NOT IN ('to-read','currently-reading','favorites','fantasy','classics',
  'young-adult','fiction','historical-fiction','science-fiction','dystopian','sci-fi','owned','non-fiction','dystopia',
  'ya','mystery','poetry','romance','harry-potter','horror')
) ranked
WHERE rank = 1
ORDER BY year ASC
--------------

-- Q4 - Quais os users mais ativos da plataforma (maior número de rankings and to_read) --
-- This query retrieves the most active users based on ratings
SELECT U.name, COUNT(R.rating)
FROM users U
JOIN ratings R ON U.user_id = R.user_id
GROUP BY U.name
ORDER BY COUNT(R.rating) DESC
LIMIT 10

-- This query retrieves the most active users based on to_read
SELECT U.name, COUNT(TR.user_id)
FROM users U
JOIN to_read TR ON U.user_id = TR.user_id
GROUP BY U.name
ORDER BY COUNT(TR.user_id) DESC
LIMIT 10
-------------

-- Q5 - Rating médio por idade/sexo dos utilizadores --
-- This query retrieves the avg rating per sex
SELECT U.sex, AVG(R.rating)
FROM users U
JOIN ratings R ON U.user_id = R.user_id
GROUP BY U.sex
------------

-- Q6 - Top 3 de Tags que têm o melhor rating atribuido
-- query took 18 min in python
SELECT T.tag_name, BT.count, AVG(S.avg_rating)
FROM tags T
JOIN book_tags BT ON BT.tag_id=T.tag_id
JOIN statistics_rating S ON S.author_id = BT.author_id
GROUP BY T.tag_name, BT.count
ORDER BY AVG(S.avg_rating) DESC
LIMIT 3
-----------


-- Q7 - Top 5 dos Livros adicionados á lista To_Read com melhor average rating
SELECT book.title, stat.avg_rating, COUNT(toread.book_id)
FROM books book
JOIN statistics_rating stat ON stat.book_id = book.book_id
JOIN to_read toread ON toread.book_id = book.book_id
GROUP BY book.title,stat.avg_rating
ORDER BY stat.avg_rating DESC
LIMIT 10


-- Q9 - Top 3 dos melhores livros portugueses (melhor average rating) na última década
SELECT DISTINCT original_title, avg_rating, book_language
FROM (
    SELECT book.original_title, AVG(stat.avg_rating) AS avg_rating, book.book_language
    FROM books book
    JOIN statistics_rating stat ON book.book_id = stat.book_id
    WHERE stat.year BETWEEN 2010 AND 2019 AND book.book_language = 'por'
    GROUP BY book.original_title, book.book_language
) AS subquery
ORDER BY avg_rating DESC
LIMIT 3
-----------


-- Q10 - Definir os dois livros com o maior diferencial de rating atribuido ( maior quantidade de rating 1 e maior quantidade de rating 5)
SELECT B.title, S.rating_1
FROM books B
JOIN statistics_rating S ON B.book_id = S.book_id
GROUP BY B.title, S.rating_1
ORDER BY S.rating_1 DESC
LIMIT 2

SELECT B.title, S.rating_5
FROM books B
JOIN statistics_rating S ON B.book_id = S.book_id
GROUP BY B.title, S.rating_5
ORDER BY S.rating_5 DESC
LIMIT 2





-- Q3 - Top 5 de autores com maior evolução (considerando o average rating) na última década
-- This query needs input -  year
SELECT A.name, AVG(S.avg_rating)
FROM authors A
JOIN statistics_rating S ON A.author_id = S.author_id
WHERE S.year = 2010
GROUP BY A.name
ORDER BY AVG(S.avg_rating) DESC
LIMIT 5
-----------


-- Q3 - Top 10 de melhores autores de sempre (average rating)
SELECT A.name, AVG(S.avg_rating)
FROM authors A
JOIN statistics_rating S ON A.author_id = S.author_id
GROUP BY A.name
ORDER BY AVG(S.avg_rating) DESC
LIMIT 10
