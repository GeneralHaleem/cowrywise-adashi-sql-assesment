# cowrywise-adashi-sql-assesment

This repo contains my SQL solutions,  a breakdown of my thought process, how I structured the query, and roadblocks I encountered.

Question 1: High-Value Customers with Multiple Products:  We want to find customers who have at least one funded savings plan and one funded investment plan.
approach:
first identified guys with funded savings plan, get their total confirmed_amount and count of savings 
next identified guys with funded investment plan, get total confirmed_amount and count of investment  
I then joined both CTEs on `owner_id`, using an inner join to ensure customers exist in both categories.
sorted by total deposits for easy identification of high-value clients.
Challenges:
 Ensuring we capture actual inflow: I added a condition to check that `confirmed_amount` is not null, since that confirms funding occurred.
also, use the plan type flags (`is_regular_savings`, `is_a_fund`) to accurately classify account types.


Question 2: Transaction Frequency Analysis: Segment customers based on their average transaction frequency per month.
approach:
first, I aggregated transactions per customer per month using last_day(transaction_date)` to bucket transactions into months.
then I averaged those monthly transactions counts per customer.
used a simple `CASE` statement to group users into High, Medium, or Low frequency buckets based on the spec.

Challenges:
initially tried using `date_trunc` but noticed inconsistencies across MySQL versions — `last_day` was more reliable here.
kept joins minimal to ensure performance, especially since this type of aggregation can grow quickly with data.

Question 3: Account Inactivity Alert: Identify savings/investment accounts that haven't had any inflow for over a year.
approach:
I filtered for accounts that are either savings or investment using the plan type flags.
checked that `confirmed_amount` is null or less than 1, as some zero-kobo transactions were being logged.
calculated the number of days since the last transaction using `datediff`.
added a HAVING clause to flag only accounts that have been inactive for 365 days or more.

Challenges:
The tricky part was making sure I wasn’t flagging inactive accounts that had been dormant since account opening, rather than just in the last year. So I made sure to only consider active accounts in recent times.
Also, had to classify plan types (`Savings` vs. `Investment`) to add context to each alert.

Question 4: Customer Lifetime Value (CLV) Estimation: Estimate customer lifetime value (CLV) using a simplified model.
approach:
for each customer, I calculated:
  account tenure using `timestampdiff(month, uc.date_joined, current_date)`.
  total transactions using a `count` on `transaction_reference`.
  average profit per transaction (assuming 0.1% of `confirmed_amount`).
Then I applied the provided formula: CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
challenges:
null values in `confirmed_amount` would have broken the `avg()` calculation, so I added a filter to exclude them.
also had to round off final values for readability.


Summary
Each query is structured for clarity and performance, with steps broken into CTEs where needed. I tried to stay close to the business logic, using clean joins and meaningful aggregations while keeping edge cases (nulls, data inconsistencies) in mind.
