
use finance;


delimiter $

-- has to be after in order to capture auto increment id
create trigger insert_transaction after INSERT on transactions for each row
 begin 
  insert into transactionaudit (transactionid, `action`, `values`) 
    values (new.id, "insert", concat_ws(",", new.`date`, new.comment, new.amount, 
            new.`type`, new.account, new.isreceiptconfirmed, new.isbankconfirmed));
 end;
$

create trigger update_transaction before UPDATE on transactions for each row
 begin
  insert into transactionaudit (transactionid, `action`, `values`) 
    values (new.id, "update", concat_ws(",", new.`date`, new.comment, new.amount,
            new.`type`, new.account, new.isreceiptconfirmed, new.isbankconfirmed));
 end;
$
 
create trigger delete_transaction before DELETE on transactions for each row
 begin 
  insert into transactionaudit (transactionid, `action`, `values`) 
    values (old.id, "delete", concat_ws(",", old.`date`, old.comment, old.amount, 
            old.`type`, old.account, old.isreceiptconfirmed, old.isbankconfirmed));
 end;
$

create trigger insert_balance after INSERT on endofmonthbalances for each row
 begin 
  insert into balanceaudit (`action`, `values`) 
    values ("insert", concat_ws(",", new.`yearid`, new.monthid, new.account, new.amount));
 end;
$

create trigger update_balance before UPDATE on endofmonthbalances for each row
 begin
  insert into balanceaudit (`action`, `values`) 
    values ("update", concat_ws(",", new.`yearid`, new.monthid, new.account, new.amount));
 end;
$
 
create trigger delete_balance before DELETE on endofmonthbalances for each row
 begin 
  insert into balanceaudit (`action`, `values`) 
    values ("delete", concat_ws(",", old.`yearid`, old.monthid, old.account, old.amount));
 end;
$
        
delimiter ;
