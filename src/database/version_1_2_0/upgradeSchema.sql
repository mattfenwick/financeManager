
use finance;


alter table transactions 
  add column savetime timestamp 
  default CURRENT_TIMESTAMP;
  
  
alter table transactions
  add column purchasedate date
  default null;
  
  
-- allow nulls for "date"
alter table transactions
  change column `date` `date` date
  default null;
  

-- adding/updating date columns:
-- 1. both booleans were checked
--    both will get the same value
-- 2. one boolean was checked
--    one date gets the value, the other is null
-- 3. neither boolean was checked
--    both dates become NULL.  data may be lost
  

update transactions
  set purchasedate = date
  where isreceiptconfirmed;
  
  
update transactions
  set date = NULL
  where not isbankconfirmed;
  
  
alter table transactions
  drop column isreceiptconfirmed;
  
  
alter table transactions
  drop column isbankconfirmed;
  
  
  
-- audit tables

CREATE TABLE `transactionaudit` (
  `id` int(11) primary key AUTO_INCREMENT,
  `time` timestamp
    default CURRENT_TIMESTAMP,
  `transactionid` int(11),
  `action` varchar(15),
  `values` varchar(150)
);


create table balanceaudit (
  `id` int(11) primary key AUTO_INCREMENT,
  `time` timestamp
    default CURRENT_TIMESTAMP,
  `action` varchar(15),
  `values` varchar(150)
);
  


-- version table

create table version (
  id         int   primary key,
  major      int,
  minor      int,
  revision   int,
  upgraded   timestamp
    default CURRENT_TIMESTAMP
);


insert into 
  version 
    (id, major, minor, revision)
  values 
    (1, 1, 2, 0);
    