select *
from countries
order by users_count desc
limit 10


/*markdown
### We want to highlight 10 wines to increase our sales. Which ones should we choose and why?
*/

/*markdown
### We have a limited marketing budget for this year. Which country should we prioritise and why?
*/



/*markdown
### We would like to give awards to the best wineries. Come up with 3 relevant ones. Which wineries should we choose and why?
*/

select
    distinct(wines.name)
from wines
join vintages on wines.id = vintages.wine_id
where vintages.name like '%Antinori%'
order by wines.ratings_count desc

select
    wines.name, vintages.name as vintage_name,
    wines.ratings_average, vintages.ratings_average as vintage_ratings_average,
    wines.ratings_count, vintages.ratings_count as vintage_ratings_count, sum(vintages.ratings_count) over (partition by wines.name) as total_ratings_count
from wines
join vintages on wines.id = vintages.wine_id
where vintages.name like '%Antinori%'
order by wines.ratings_count desc


select
    wines.name, vintages.name as vintage_name,
    STRCMP (wines.name, vintages.name) as name_check,
    wines.ratings_average, vintages.ratings_average as vintage_ratings_average,
    wines.ratings_count, vintages.ratings_count as vintage_ratings_count, sum(vintages.ratings_count) over (partition by wines.name) as total_ratings_count
from wines
join vintages on wines.id = vintages.wine_id
order by wines.ratings_count desc

"""
UPDATE countries
SET wineries_user_ratio = users_count / wineries_count
WHERE users_count > 0;
"""

select count(distinct winery_id)
from wines

select count(distinct wine_id)
from vintages

select *
from vintages

