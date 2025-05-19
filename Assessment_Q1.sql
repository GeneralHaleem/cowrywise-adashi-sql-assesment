use adashi_staging;

-- first identified guys with funded savings plan, get their total confirmed_amount and count of savings 
with savings as (
select
sa.owner_id as owner_id,
sum(sa.confirmed_amount) as savings_total,
sum(is_regular_savings) as savings_count
from savings_savingsaccount sa
left join plans_plan pp on pp.id = sa.plan_id
where pp.is_regular_savings = 1
and sa.confirmed_amount is not null
group by 1
),

-- next identified guys with funded investment  plan, get total confirmed_amount and count of investment  
investment as (
select
sa.owner_id as owner_id,
sum(sa.confirmed_amount ) as investment_total, 
sum(is_a_fund) as investment_count 
from savings_savingsaccount sa 
left join plans_plan pp on pp.id = sa.plan_id
where pp.is_a_fund = 1
and sa.confirmed_amount is not null
group by 1
) 

-- used users_customuser as mother table and inner join to both cte's created, used inner join to ensure that uc.id in users_customuser exists in both cte's
select  
uc.id as owner_id,
concat(uc.first_name, ' ', uc.last_name) as name,
sa.savings_count as savings_count, 
inv.investment_count as investment_count, 
round((inv.investment_total + sa.savings_total), 2) as total_deposit
from users_customuser uc  
inner join savings sa on uc.id = sa.owner_id 
inner join investment inv on uc.id = inv.owner_id 
order by (inv.investment_total + sa.savings_total) desc