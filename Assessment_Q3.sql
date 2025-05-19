use adashi_staging;

select 
pp.id as plan_id,
pp.owner_id as owner_id,
-- classify the plan as either 'Savings' or 'Investment'
case 
	when is_regular_savings = 1 then 'Savings'
    when is_a_fund = 1 then 'Investment'
end as type,
date(max(transaction_date)) as last_transaction_date,  
datediff(current_date, max(transaction_date)) as inactivity_days
from plans_plan pp
left join savings_savingsaccount sa on pp.id = sa.plan_id
where (is_regular_savings = 1 or is_a_fund = 1) -- to ensure the account is either savings or investment 
and (confirmed_amount < 1 or confirmed_amount is null) -- to ensure the account does not have inflow transaction. used confirmed_amount < 1 cause some inflow are 0 kobo 
group by pp.id, pp.owner_id
-- include only plans that have been active within the last 365 days
having datediff(current_date, max(transaction_date)) <= 365;