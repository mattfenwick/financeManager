create user 'username'@'localhost' identified by 'password';

create database if not exists finance;

GRANT SELECT,INSERT,UPDATE,DELETE on finance.* to 'username'@'localhost';



use finance;

-- the core tables
-- transactions, endofmonthbalances can be accessed directly 
--    to perform inserts and updates only
-- for information retrieval, the views should be used

drop table if exists myaccounts;
create table myaccounts (
    name varchar(20)        primary key
);


drop table if exists transactiontypes;
create table transactiontypes (
    description varchar(20)   primary key,
    multiplier int            NOT NULL
);

drop table if exists transactions;
create table transactions (
    id int                  primary key auto_increment,
    `date` date             NOT NULL,
    comment varchar(50)     NOT NULL,
    amount decimal(10, 2)   NOT NULL,
    type varchar(20)        NOT NULL,
    account varchar(20)     NOT NULL,
    isreceiptconfirmed bool NOT NULL,
    isbankconfirmed bool    NOT NULL,
      foreign key (account) references myaccounts(name),
      foreign key (type) references transactiontypes(description)
);


drop table if exists months;
create table months (
    id int                  primary key,
    name varchar(10)        NOT NULL
);

drop table if exists years;
create table years (
    id int                  primary key
);

drop table if exists endofmonthbalances;
create table endofmonthbalances (
    monthid int,
    yearid int,
    amount decimal(10,2)    NOT NULL,
    account varchar(20),
    primary key (account, monthid, yearid),
    foreign key (account) references myaccounts(name),
    foreign key (monthid) references months(id),
    foreign key (yearid) references years(id)
);



-- reference data

INSERT INTO `transactiontypes` VALUES ('Check withdrawal',-1),('Check deposit',1),('Debit card charge',-1),('Credit card charge',-1),('Cash withdrawal',-1),('Cash deposit',1),('Direct deposit',1),('Direct withdrawal',-1),('General deposit', 1),('General withdrawal', -1);

INSERT INTO `years` VALUES (2000),(2001),(2002),(2003),(2004),(2005),(2006),(2007),(2008),(2009),(2010),(2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018),(2019),(2020),(2021),(2022),(2023),(2024),(2025);

INSERT INTO `myaccounts` VALUES ('Checking'),('Savings'),('Credit card');

INSERT INTO `months` VALUES (1,'January'),(2,'February'),(3,'March'),(4,'April'),(5,'May'),(6,'June'),(7,'July'),(8,'August'),(9,'September'),(10,'October'),(11,'November'),(12,'December');

