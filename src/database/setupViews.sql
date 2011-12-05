use finance;

-- p_ prefix identifies 'public' views, i.e. views that client programs are allowed to query


-- transactions 'sanitized' for perusal by multiplying withdrawals by -1 (based on `transactiontypes` table)
drop view if exists p_transactions;
create view p_transactions as
    select 
        id, 
        `date`, 
        comment, 
        amount * multiplier as amount,
        `type`,
        account,
        isreceiptconfirmed as `have receipt`,
        isbankconfirmed as `bank-confirmed`
    from 
        transactions as t
    inner join 
        transactiontypes as tt
        on `type` = description;


drop view if exists p_commentcounts;
create view p_commentcounts as 
    select 
        count(*) as number, 
        comment from transactions 
    group by hex(comment);


drop view if exists p_transactiontypecounts;
create view p_transactiontypecounts as
    select 
        count(*) as `number of transactions`,
        `type` as `transaction type`,
        `account`
    from
        transactions
    group by
        type, account;


drop view if exists p_monthlytotals;
create view p_monthlytotals as
    select 
        sum(amount) as `sum of transactions`, 
        month(date) as `month`, 
        year(date) as `year`, 
        account
    from 
        p_transactions
    where
        `bank-confirmed`
    group by 
        account, 
        year(date), 
        month(date);


drop view if exists p_endofmonthbalances;
create view p_endofmonthbalances as
    select
        amount,
        monthid as `month`,
        yearid as `year`,
        account
    from 
        endofmonthbalances;


-- look for duplicates based on identical comments and amounts
-- (this is not a 'public' view)
drop view if exists v_potentialduplicates;
create view v_potentialduplicates as
    select
        amount,
        comment,
        count(*) as count,
        group_concat(date) as dates
    from
        p_transactions
    group by
        amount,
        comment;
        
        
drop view if exists p_potentialduplicates;
create view p_potentialduplicates as
    select
        *
    from 
        v_potentialduplicates
    where
        count > 1;


drop view if exists p_transactionspermonth;
create view p_transactionspermonth as
    select 
        count(*) as `number of transactions`,
        month(date) as month,
        year(date) as year,
        account
    from 
        p_transactions 
    group by 
        month(date), year(date), account;


drop view if exists p_recenttransactions;
create view p_recenttransactions as
    select
        *
    from
        p_transactions
    order by
        id DESC
    limit 30;
