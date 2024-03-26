select *
from countries
order by users_count desc
limit 10


/*markdown
- grapes wines count is the same for each country

*/

/*markdown
### We want to highlight 10 wines to increase our sales. Which ones should we choose and why?

*/

/*markdown

### We have a limited marketing budget for this year. Which country should we prioritise and why?

*/

select *, users_count/wines_count as n_wines_per_user, users_count/wineries_count as n_wineries_per_user
from countries
order by n_wines_per_user desc


/*markdown
### We would like to give awards to the best wineries. Come up with 3 relevant ones. Which wineries should we choose and why?
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
### We detected that a big cluster of customers likes a specific combination of tastes. We identified a few keywords that match these tastes: coffee, toast, green apple, cream, and citrus (note that these keywords are case sensitive). We would like you to find all the wines that are related to these keywords. Check that at least 10 users confirm those keywords, to ensure the accuracy of the selection. Additionally, identify an appropriate group name for this cluster.
*/

select
    wines.name as wine_name,
    keywords_wine.*,
    keywords.name as keyword_name
from wines
join keywords_wine on wines.id = keywords_wine.wine_id
join keywords on keywords_wine.keyword_id = keywords.id
where keywords.name in ('coffee', 'toast', 'green apple', 'cream', 'citrus')
    and keywords_wine.count >= 10
group by wine_name
having count(distinct(keyword_name)) >= 5

/*markdown
### We would like to select wines that are easy to find all over the world. Find the top 3 most common grapes all over the world and for each grape, give us the the 5 best rated wines.
*/

select
    grapes.name as grape_name,
    sum(countries.wines_count) as total_wines_count

from countries
join most_used_grapes_per_country on countries.code = most_used_grapes_per_country.country_code
join grapes on most_used_grapes_per_country.grape_id = grapes.id
group by grape_name
order by total_wines_count desc


