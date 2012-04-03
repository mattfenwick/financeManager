
use finance;


CREATE TABLE `transactionaudit` (
  `id` int(11) primary key AUTO_INCREMENT,
  `time` timestamp
    default CURRENT_TIMESTAMP,
  `transactionid` int(11),
  `action` varchar(15),
  `values` varchar(500)
);



delimiter $

-- has to be after in order to capture auto increment id
create trigger insert_transaction after INSERT on transactions for each row
 begin 
  insert into transactionaudit (transactionid, `action`, `values`) 
    values (new.id, "insert", concat_ws(",", new.`date`, new.amount, new.`type`, 
            new.account, new.isreceiptconfirmed, new.isbankconfirmed));
 end;
$


create trigger update_transaction before UPDATE on transactions for each row
 begin
  insert into transactionaudit (transactionid, `action`, `values`) 
    values (new.id, "update", concat_ws(",", new.`date`, new.amount, new.`type`, 
            new.account, new.isreceiptconfirmed, new.isbankconfirmed));
 end;
$
 
 
create trigger delete_transaction before DELETE on transactions for each row
 begin 
  insert into transactionaudit (transactionid, `action`, `values`) 
    values (old.id, "delete", concat_ws(",", old.`date`, old.amount, old.`type`, 
            old.account, old.isreceiptconfirmed, old.isbankconfirmed));
 end;
$

            
delimiter ;
            