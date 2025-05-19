use adashi_staging;

with 
-- first calculate metirics per onwer 
user_cust as (
select 
uc.id as owner_id,
concat(uc.first_name, ' ', uc.last_name) as name,
timestampdiff(month, uc.date_joined, current_date) as account_tenure,
count(sa.transaction_reference) as total_transaction,
avg(0.001 * sa.confirmed_amount) as avg_profit_per_transaction  -- assuming the profit_per_transaction is 0.1%
from users_customuser uc 
left join savings_savingsaccount sa on uc.id = sa.owner_id
where confirmed_amount is not null -- since avg_profit_per_transaction sa.confirmed_amount we need to ensure confirmed_amount is not null  
group by uc.id 
)

-- calulated estimated_clv for each owner since it has been previously aggregated by owner_id in previous cte  
select
owner_id as customer_id,
name,
account_tenure as tenure_months, 
total_transaction, 
round(((total_transaction/account_tenure) * 12 * avg_profit_per_transaction), 2) as estimated_clv
from user_cust uct
order by round(((total_transaction/account_tenure) * 12 * avg_profit_per_transaction), 2) desc;