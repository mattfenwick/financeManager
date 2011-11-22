use finance;



-- date, account of earliest end-of-month balances
drop view if exists v_earliestdates;
create view v_earliestdates as 
    select 
        min(date(concat(yearid, "-", monthid, "-0"))) as `date`, 
        `account` 
    from 
        endofmonthbalances 
    group by 
        `account`;


-- amount, account of earliest end-of-month balances
drop view if exists v_earliestbalances;
create view v_earliestbalances as 
    select 
        amount,
        e2.`account`
    from 
        v_earliestdates as e,
        endofmonthbalances as e2
    where 
        month(`date`) = monthid and 
        year(`date`) = yearid and 
        e.account = e2.account;


-- get month, year, account of months of interest 
--   MOIs are all those months that have a declared end-of-month balance
drop view if exists v_step1;
create view v_step1 as
    select 
        monthid as month,
        yearid as year,
        account
    from
        endofmonthbalances;


-- add in the DATE of the earliest declared balance for the account
-- change to:
-- select `date`, `month`, `year`, `account` ... rest of query ...;
--      (account can be from either table)
drop view if exists v_step2;
create view v_step2 as
    select
        *
    from
        v_step1
    inner join
        v_earliestdates
    using (account);


-- get the amounts from all the transactions within the date range (only 'bank confirmed')
drop view if exists v_step3;
create view v_step3 as
    select
        p.amount,
        v.month,
        v.year,
        v.account
    from
        p_transactions as p,
        v_step2 as v
    where
        p.date >= v.date and                  -- transaction is on or after date of earliest declared balance
        (year(p.date) < v.year or             -- and the transaction is before or during the month-of-interest
            (month(p.date) <= v.month and     -- based on:
                year(p.date) = v.year)) and   --     year of transaction before year of MOI
        p.account = v.account and             --     or year is same, but month is same or earlier (than MOI)
        p.`bank-confirmed`;


-- aggregate the transactions by month, year, account 
drop view if exists v_step4;
create view v_step4 as
    select 
        sum(amount) as `sum`,
        month, 
        year,
        account
    from
        v_step3
    group by 
        month, year, account;


-- add in the initial balance (that is, the earliest balance)
drop view if exists v_step5;
create view v_step5 as
    select
        `sum` + amount as `calculated balance`,
        month,
        year,
        account
    from
        v_step4
    inner join
        v_earliestbalances
    using (account);


-- compare the calculated sums to the declared sums
drop view if exists p_comparison;
create view p_comparison as
    select
        `calculated balance`,
        amount as `declared balance`,
        `calculated balance` - `amount` as `difference`,
        month, 
        year,
        e.account
    from 
        endofmonthbalances as e
    inner join
        v_step5 as v
    on
        month = monthid and
        year = yearid and
        e.account = v.account;

        
-- ----------------------------------------------------
-- views for running total per transaction
-- ----------------------------------------------------

-- for each transaction (that is confirmed by the bank)
--   get amount, date of all transactions that preceded it
drop view if exists v_groupedtrans;
create view v_groupedtrans as
    select
        l.id,
        l.account,
        r.date,
        r.amount
    from
        p_transactions as l
    inner join
        p_transactions as r
    on
        l.account = r.account and
        (r.date < l.date or
          (r.date = l.date and r.id <= l.id))
    where
        l.`bank-confirmed` and r.`bank-confirmed`;
        

drop view if exists v_firstbalance;
create view v_firstbalance as
    select
        account,
        `date`,
        amount as `balance`
    from 
        v_earliestbalances
    inner join
        v_earliestdates
    using
        (account);
        
        
drop view if exists v_idamounts;
create view v_idamounts as
    select 
        l.id,
        sum(l.amount) + r.balance as `current balance`
    from
        v_groupedtrans as l
    inner join
        v_firstbalance as r
    using
        (account)
    where
        l.date >= r.date
    group by
        l.id;
        

drop view if exists p_runningtotals;
create view p_runningtotals as
    select
        *
    from
        v_idamounts
    inner join
        p_transactions
    using
        (id)
    order by
        date, id;
