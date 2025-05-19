use adashi_staging;

--  first, aggregated customer transactions per month
with customers_monthly_trx as (
select 
last_day(sa.transaction_date) as trx_month,
uc.id as owner_id,
count(sa.transaction_reference) as trx_count
from savings_savingsaccount sa
inner join users_customuser uc on uc.id = sa.owner_id 
group by last_day(transaction_date), uc.id 
)

-- calculated average monthly transactions per customer per month and assign a frequency category
, customers_monthly_avg_trx as (
select 
owner_id, 
avg(trx_count) as avg_transactions_per_month, 
case 
	when avg(trx_count) >= 10 then 'High Frequency'
    when avg(trx_count) >= 3 then 'Medium Frequency'
    when avg(trx_count) < 3 then 'Low Frequency'
end as frequency_category
from customers_monthly_trx 
group by owner_id
)

-- summarized customer frequency categories and their average transactions by grouping by frequency_category 
select 
frequency_category, 
count(owner_id) as customer_count, 
round(avg(avg_transactions_per_month), 1) as avg_transactions_per_month
from customers_monthly_avg_trx
group by frequency_category
order by round(avg(avg_transactions_per_month), 1) desc;