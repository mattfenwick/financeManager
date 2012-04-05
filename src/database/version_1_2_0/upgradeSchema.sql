
use finance;


alter table transactions 
  add column savetime timestamp 
  default CURRENT_TIMESTAMP;
  
  
alter table transactions
  add column purchasedate date
  not null;
  
  
update transactions
  set purchasedate = date;


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
    