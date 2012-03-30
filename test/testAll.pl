use strict;
use warnings;

use Test::More;
use Try::Tiny;

use Log::Log4perl qw(:easy);
BEGIN {
    Log::Log4perl->easy_init({
        level   => $DEBUG,
        file    => ">testLog.txt",
        layout  => '%p  %F{1}-%L-%M: (%d) %m%n' 
    });
}

use TestImports; # runs at compile time ???

use TestMessages;
use TestReport;
use TestBalance;
use TestTransaction;

use TestDatabase;
use TestReportMapper;
use TestBalanceMapper;
use TestTransactionMapper;

use TestMiscData;
use TestService;
use TestModelListeners;


&TestMessages::runTests();
&TestReport::runTests();
&TestBalance::runTests();
&TestTransaction::runTests();


&TestModelListeners::runTests();
&TestDatabase::runTests();
&TestReportMapper::runTests();
&TestBalanceMapper::runTests();
&TestTransactionMapper::runTests();
&TestMiscData::runTests();
&TestService::runTests();


&done_testing();
