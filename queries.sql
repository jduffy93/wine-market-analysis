select *
from countries
order by users_count desc
limit 10



/*markdown
### 1/7 - We want to highlight 10 wines to increase our sales. Which ones should we choose and why?
___


*/

/*markdown
### 2/7 -  We have a limited marketing budget for this year. Which country should we prioritise and why?
___
*/

select
    *,
    users_count/wines_count as n_wines_per_user,
    users_count/wineries_count as n_wineries_per_user
from countries
order by n_wines_per_user desc

/*markdown
### 3/7 - We would like to give awards to the best wineries. Come up with 3 relevant ones. Which wineries should we choose and why?
___
*/

select
    wines.name as wine_name, wines.winery_id,
    wines.ratings_average,
    vintages.wine_id,
    vintage_toplists_rankings.vintage_id, vintage_toplists_rankings.rank,
    toplists.name as toplist_name
from wines
join vintages on wines.id = vintages.wine_id
join vintage_toplists_rankings on vintages.id = vintage_toplists_rankings.vintage_id
join toplists on vintage_toplists_rankings.top_list_id = toplists.id
limit 10

select
    wines.name as wine_name, wines.winery_id,
    wines.ratings_average,
    round(avg(wines.ratings_average),2) as avg_rating,
    sum(wines.ratings_count) as total_ratings,
    vintage_toplists_rankings.vintage_id,
    toplists.name as toplist_name,
    count(winery_id) as winery_count,
    round(avg(vintage_toplists_rankings.rank),2) as avg_rank

from wines
join vintages on wines.id = vintages.wine_id
join vintage_toplists_rankings on vintages.id = vintage_toplists_rankings.vintage_id
join toplists on vintage_toplists_rankings.top_list_id = toplists.id
group by wines.winery_id
order by avg_rank asc, winery_count desc
limit 20

select
    wines.name as wine_name, wines.winery_id,
    wines.ratings_average,
    vintages.wine_id,
    vintage_toplists_rankings.vintage_id,
    toplists.name as toplist_name

from wines
join vintages on wines.id = vintages.wine_id
join vintage_toplists_rankings on vintages.id = vintage_toplists_rankings.vintage_id
join toplists on vintage_toplists_rankings.top_list_id = toplists.id
where wines.winery_id = 1252	




select
    distinct(wines.name), wines.winery_id
from wines
join vintages on wines.id = vintages.wine_id
where vintages.name like '%Antinori%'
order by wines.ratings_count desc

select
    wines.name, vintages.name as vintage_name, wines.winery_id,
    CASE
        WHEN INSTR(vintages.name, wines.name) > 0 THEN
            TRIM(SUBSTR(vintages.name, 1, INSTR(vintages.name, wines.name) - 1))
        ELSE
            vintages.name
    END AS wine_name_cleaned
from wines
join vintages on wines.id = vintages.wine_id
group by wines.winery_id
order by wines.ratings_count desc
limit 10


select
    wines.name, vintages.name as vintage_name, wines.winery_id
    ,wines.ratings_average, vintages.ratings_average as vintage_ratings_average
    ,wines.ratings_count, vintages.ratings_count as vintage_ratings_count, sum(vintages.ratings_count) over (partition by wines.name) as total_ratings_count
from wines
join vintages on wines.id = vintages.wine_id
where vintages.name like '%Antinori%'
order by wines.ratings_count desc
limit 10

/*markdown
### 4/7 -  We detected that a big cluster of customers likes a specific combination of tastes. We identified a few keywords that match these tastes: coffee, toast, green apple, cream, and citrus (note that these keywords are case sensitive). We would like you to find all the wines that are related to these keywords. Check that at least 10 users confirm those keywords, to ensure the accuracy of the selection. Additionally, identify an appropriate group name for this cluster.
___
*/

select
    wines.name as wine_name,
    keywords_wine.*
from wines
join keywords_wine on wines.id = keywords_wine.wine_id
join keywords on keywords_wine.keyword_id = keywords.id
where keywords.name in ('coffee', 'toast', 'green apple', 'cream', 'citrus')
    and keywords_wine.count >= 10
group by wine_name
having count(distinct(keywords.name)) >= 5

/*markdown
### 5/7 - We would like to select wines that are easy to find all over the world. Find the top 3 most common grapes all over the world and for each grape, give us the the 5 best rated wines.
___
*/

/*markdown
First we find the most common grapes in the world. There are two methods which can be used:
1. We assume that the number of wines (wines_cout in most_used_grapes_per_country) is representative of the number of grapes.
2. We count the number of countries that have a specific type of grape


We went with the first option
*/

select
    grapes.name as grape_name,
    AVG(most_used_grapes_per_country.wines_count) as wines_count
from most_used_grapes_per_country
join grapes on most_used_grapes_per_country.grape_id = grapes.id
group by grape_name
order by wines_count desc
limit 3

SELECT
    subquery.wine_name,
    subquery.winery_name,
    subquery.ratings_average,
    subquery.grape_name
FROM
    (
        SELECT
            wines.name AS wine_name,
            wines.ratings_average,
            grapes.name AS grape_name,
            wineries.name AS winery_name,
            ROW_NUMBER() OVER (PARTITION BY grapes.name ORDER BY wines.ratings_average DESC) AS row_num
        FROM
            countries
            JOIN regions ON countries.code = regions.country_code
            JOIN wines ON regions.id = wines.region_id
            JOIN most_used_grapes_per_country ON countries.code = most_used_grapes_per_country.country_code
            JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
            JOIN wineries ON wines.winery_id = wineries.id
        WHERE
            grapes.name IN ('Cabernet Sauvignon', 'Chardonnay', 'Pinot Noir')
    ) AS subquery
WHERE
    subquery.row_num <= 8
ORDER BY
    subquery.grape_name,
    subquery.ratings_average DESC


SELECT
    subquery.wine_name,
    subquery.vintage_name,
    subquery.ratings_average,
    subquery.grape_name
FROM
    (
        SELECT
            wines.name AS wine_name,
            wines.ratings_average,
            grapes.name AS grape_name,
            vintages.name AS vintage_name,
            ROW_NUMBER() OVER (PARTITION BY grapes.name ORDER BY wines.ratings_average DESC) AS row_num
        FROM
            countries
            JOIN regions ON countries.code = regions.country_code
            JOIN wines ON regions.id = wines.region_id
            JOIN most_used_grapes_per_country ON countries.code = most_used_grapes_per_country.country_code
            JOIN grapes ON most_used_grapes_per_country.grape_id = grapes.id
            JOIN vintages ON wines.id = vintages.wine_id
        WHERE
            grapes.name IN ('Cabernet Sauvignon', 'Chardonnay', 'Pinot Noir')
    ) AS subquery
WHERE
    subquery.row_num <= 20
ORDER BY
    subquery.grape_name,
    subquery.ratings_average DESC



/*markdown
### 6/7 - We would like to create a country leaderboard. Come up with a visual that shows the average wine rating for each country. Do the same for the vintages.
___
*/

SELECT countries.name AS country_name, ROUND(AVG(wines.ratings_average),2) AS average_rating
FROM countries
JOIN regions ON countries.code = regions.country_code
JOIN wines ON regions.id = wines.region_id
GROUP BY country_name
ORDER BY average_rating DESC

SELECT countries.name AS country_name, ROUND(AVG(vintages.ratings_average), 2) AS average_vintage_rating
FROM countries
JOIN regions ON countries.code = regions.country_code
JOIN wines ON regions.id = wines.region_id
JOIN vintages ON wines.id = vintages.wine_id
GROUP BY country_name
ORDER BY average_vintage_rating DESC



/*markdown
### 7/7 - One of our VIP clients likes Cabernet Sauvignon and would like our top 5 recommendations. Which wines would you recommend to him?
___
*/

SELECT
    vintages.name AS vintage_name,
    ROUND(AVG(wines.ratings_average), 2) AS ratings_average,
    ROUND(AVG(vintage_toplists_rankings.rank),2) AS average_rank,
    COUNT(wines.ratings_average) AS number_of_ratings
FROM
    wines
JOIN
    vintages ON wines.id = vintages.wine_id,
    vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id,
    regions ON wines.region_id = regions.id,
    countries ON regions.country_code = countries.code,
    most_used_grapes_per_country ON countries.code = most_used_grapes_per_country.country_code,
    grapes ON most_used_grapes_per_country.grape_id = grapes.id
WHERE
    grapes.name LIKE '%Cabernet Sauvignon%'
GROUP BY
    vintage_name
ORDER BY
    ratings_average DESC



SELECT
    vintages.name AS vintage_name,
    toplists.name AS toplist_name
    --ROUND(AVG(wines.ratings_average), 2) AS ratings_average,
    --ROUND(AVG(vintage_toplists_rankings.rank),2) AS average_rank
FROM
    vintages
JOIN
    vintage_toplists_rankings ON vintages.id = vintage_toplists_rankings.vintage_id,
    toplists ON vintage_toplists_rankings.top_list_id = toplists.id
WHERE
    vintages.name LIKE '%Cabernet Sauvignon%'
GROUP BY
    vintage_name
--ORDER BY
    --ratings_average DESC



SELECT
    vintages.name AS vintage_name,
    vintages.ratings_average,
    vintages.ratings_count,
    countries.name AS country_name,
    regions.name AS region_name
FROM
    wines
JOIN
    vintages ON wines.id = vintages.wine_id,
    regions ON wines.region_id = regions.id,
    countries ON regions.country_code = countries.code
WHERE
    countries.name LIKE '%France%'
ORDER BY
    vintages.ratings_average DESC
LIMIT 10 

SELECT
    vintages.name AS vintage_name,
    vintages.ratings_average,
    vintages.ratings_count,
    keywords_wine.count,
    keywords.*
FROM
    wines
JOIN
    vintages ON wines.id = vintages.wine_id,
    keywords_wine ON wines.id = keywords_wine.wine_id,
    keywords ON keywords_wine.keyword_id = keywords.id
WHERE
    --keywords_wine.count >= 50
    vintage_name == 'Château Lafite Rothschild Pauillac (Premier Grand Cru Classé) 2003'
GROUP BY
    keywords.name
ORDER BY
    keywords_wine.count DESC, keywords.name ASC

SELECT *
FROM (
    SELECT
        vintages.name AS vintage_name,
        vintages.ratings_average,
        vintages.ratings_count,
        keywords_wine.count,
        keywords.name AS keyword_name,
        ROW_NUMBER() OVER (PARTITION BY vintages.name ORDER BY keywords_wine.count DESC) AS row_num
    FROM
        wines
    JOIN
        vintages ON wines.id = vintages.wine_id,
        keywords_wine ON wines.id = keywords_wine.wine_id,
        keywords ON keywords_wine.keyword_id = keywords.id
    WHERE
        keywords_wine.count >= 20
        --vintage_name == 'Château Lafite Rothschild Pauillac (Premier Grand Cru Classé) 2003'
    GROUP BY
        vintage_name,
        keyword_name,
        vintages.ratings_average,
        vintages.ratings_count,
        keywords_wine.count
) AS subquery
WHERE
    row_num <= 3 AND vintage_name LIKE '%Cabernet Sauvignon%'
ORDER BY
    vintage_name ASC,
    count DESC

