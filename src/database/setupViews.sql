use finance;

-- p_ prefix identifies 'public' views, i.e. views that client programs are allowed to query


drop view if exists p_transactions;
create view p_transactions as
    select 
        id, 
        `date`, 
        comment, 
        amount * multiplier as amount,
        `type`,
        account,
        isreceiptconfirmed,
        isbankconfirmed
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


drop view if exists p_typecounts;
create view p_typecounts as
    select 
        count(*) as number,
        `type`
    from
        transactions as t
    group by
        type;


drop view if exists p_monthlytotals;
create view p_monthlytotals as
    select 
        sum(amount), 
        year(date), 
        month(date), 
        account
    from p_transactions
    group by 
        account, 
        year(date), 
        month(date);


drop view if exists p_endofmonthbalances;
create view p_endofmonthbalances as
    select
        monthid,
        yearid,
        amount,
        account
    from 
        endofmonthbalances;

drop view if exists p_potentialduplicates;
create view p_potentialduplicates as
    select
        l.id as `id1`,
        `l`.`date` as `date1`,
        l.amount as `amount`,
        l.comment as `comment`,
        r.id as `id2`,
        `r`.`date` as `date2` 
    from
        p_transactions as l
    inner join
        p_transactions as r
    on
        l.id < r.id and
        l.amount = r.amount and
        l.comment = r.comment;
