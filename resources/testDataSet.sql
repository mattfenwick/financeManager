

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES 
  (142,'2011-01-01','oh noes!!!!','4.00','Cash deposit','Checking',0,0),
  (143,'2011-11-09','oh noes!!!! 34','4.00','Cash deposit','Checking',0,0),
  (144,'2011-11-10','oh noes!!!! 34  67','4.00','Cash deposit','Checking',0,0),
  (145,'2011-11-16','fake transaction','56.00','Direct withdrawal','Credit card',1,1),
  (146,'2012-01-01','joke joke','85.00','General deposit','Checking',1,1),
  (147,'2011-06-30','maybe some food','920.00','Cash withdrawal','Savings',1,0),
  (149,'2010-11-14','Interesting toy','4.60','Debit card charge','Savings',0,1),
  (159,'2011-04-05','Bill for something ?????','76.93','Check withdrawal','Savings',0,0),
  (160,'2011-02-00','more pizza!!!!','789.06','Cash withdrawal','Checking',0,1),
  (161,'2011-06-09','paycheck','188.00','Direct deposit','Checking',1,1),
  (162,'2010-10-19','omg i like chocolate','78.55','Credit card charge','Credit card',1,1),
  (163,'2015-01-22','pizza ... again ! but this time i made it!','89.00','Cash deposit','Checking',1,0),
  (164,'2013-08-04','some other restaurant','39.22','Credit card charge','Credit card',0,1),
  (165,'2013-02-02','groceries','19.79','Debit card charge','Checking',1,1),
  (166,'2014-04-06','hardware store','78.00','Cash withdrawal','Savings',0,0),
  (167,'2011-09-05','paycheck','44.03','Direct deposit','Checking',1,1),
  (168,'2010-12-21','forgot ??? bad memory','17.93','Cash deposit','Checking',0,1),
  (170,'2011-07-14','pizza ... yet again','10.72','Check withdrawal','Checking',1,1),
  (171,'2011-10-15','paycheck','10009.22','Direct deposit','Savings',1,1),
  (173,'2011-07-31','I\'m a travelling man','29.99','Cash withdrawal','Checking',1,1),
  (176,'2018-06-07','gorillas eating bananas','765.32','Cash deposit','Checking',0,1),
  (177,'2011-04-07','fake transaction','32.32','Cash deposit','Savings',1,1),
  (178,'2010-10-07','fake transaction','13.31','Cash deposit','Checking',1,1),
  (179,'2010-09-07','fake transaction','13.39','Cash deposit','Checking',1,1);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `endofmonthbalances`
--

LOCK TABLES `endofmonthbalances` WRITE;
/*!40000 ALTER TABLE `endofmonthbalances` DISABLE KEYS */;
INSERT INTO `endofmonthbalances` VALUES 
  (1,2011,'234.56','Checking'),
  (2,2011,'234.56','Checking'),
  (3,2011,'234.56','Checking'),
  (4,2011,'234.56','Checking'),
  (5,2011,'234.56','Checking'),
  (10,2010,'1234.56','Checking'),
  (11,2010,'234.56','Checking'),
  (12,2010,'234.56','Checking'),
  (8,2011,'234.56','Credit card'),
  (1,2011,'234.56','Savings'),
  (2,2011,'234.56','Savings'),
  (2,2014,'78.34','Savings'),
  (3,2011,'234.56','Savings'),
  (4,2011,'234.56','Savings'),
  (5,2011,'234.56','Savings'),
  (10,2010,'234.56','Savings'),
  (11,2010,'234.56','Savings'),
  (12,2010,'234.56','Savings');
/*!40000 ALTER TABLE `endofmonthbalances` ENABLE KEYS */;
UNLOCK TABLES;
