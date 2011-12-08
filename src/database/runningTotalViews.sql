use finance;


-- EOMB: declared end of month balance
-- EEOMB: earliest EOMB
-- MOI: month of interest. An EOMB of an account, after the EEOMB of the account
-- TOI: transaction of interest.  Must be bank-confirmed.  After the EEOMB of its account.


-- date (with 0 filled in for day), account of EEOMB
drop view if exists v_earliestdates;
create view v_earliestdates as 
    select 
        min(date(concat(yearid, "-", monthid, "-0"))) as `date`, 
        `account` 
    from 
        endofmonthbalances 
    group by 
        `account`;
        
-- month, year, account of EEOMB
drop view if exists v_eeomb_date;
create view v_eeomb_date as
    select
        month(date) as `month`,
        year(date)  as `year`,
        account
    from
        v_earliestdates;


-- amount, account of earliest end-of-month balances
drop view if exists v_earliestbalances;
create view v_earliestbalances as 
    select 
        r.amount,
        r.`account`
    from 
        v_eeomb_date as l
    inner join
        endofmonthbalances as r
    on
        l.month   = r.monthid and 
        l.year    = r.yearid and 
        l.account = r.account;


-- get month, year, account of MOIs
drop view if exists v_step1;
create view v_step1 as
    select 
        l.monthid as month,
        l.yearid as year,
        l.account
    from
        endofmonthbalances as l
    inner join
        v_eeomb_date as r
    on
        l.account = r.account and
        (l.monthid != r.month or
          l.yearid != r.year);


-- add in the DATE of the EEOMB for the account
drop view if exists v_step2;
create view v_step2 as
    select
        l.month,
        l.year,
        l.account,
        r.month as `month_eeomb`,
        r.year as `year_eeomb`
    from
        v_step1 as l
    inner join
        v_eeomb_date as r
    using 
        (account);


-- get the amounts from all the TOIs
drop view if exists v_step3;
create view v_step3 as
    select
        p.amount,
        v.month,
        v.year,
        v.account,
        p.date as `TOI_date`,
        v.`month_eeomb`,
        v.`year_eeomb`
    from
        p_transactions as p
    inner join
        v_step2 as v
      on
          p.account = v.account           
    where
        (year(p.date) > v.year_eeomb or           -- TOI is after EEOMB
          (year(p.date) = v.year_eeomb and
            month(p.date) > v.month_eeomb)) AND
        (year(p.date) < v.year or                 -- and TOI is before or during associated MOI
          (month(p.date) <= v.month and     
            year(p.date) = v.year)) AND  
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

drop view if exists v_tois;
create view v_tois as 
    select
        l.*
    from
        p_transactions as l
    inner join
        v_eeomb_date as r
    using
        (account)
    where
        l.`bank-confirmed` and
        (year(l.date) > r.year or
          (year(l.date) = r.year and
            month(l.date) > r.month));
            

-- for each TOI
--   get amount from each TOI that preceded it
--   TOI x precedes TOI y if x and y have the same account,
--     and x's date is before y's date, or they have the same date but x's id is smaller
drop view if exists v_joined_tois;
create view v_joined_tois as
    select
        l.id,
        l.account,
        r.amount
    from
        v_tois as l
    inner join
        v_tois as r
    on
        l.account = r.account and
        (r.date < l.date or
          (r.date = l.date and r.id <= l.id));
        

-- id of each TOI, vs. sum of all previous TOIs and EEOMB
drop view if exists v_idamounts;
create view v_idamounts as
    select 
        l.id,
        sum(l.amount) + r.amount as `current balance`
    from
        v_joined_tois as l
    inner join
        v_earliestbalances as r
    using
        (account)
    group by
        l.id;
        

-- add current balance in to p_transactions
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
