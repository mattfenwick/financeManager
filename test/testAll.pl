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
use TestDatabase;

use TestReport;
use TestReportMapper;
use TestBalance;
use TestBalanceMapper;
use TestTransaction;
use TestTransactionMapper;

use TestMiscData;
use TestService;
use TestModelListeners;


&TestMessages::runTests();

&TestReport::runTests();
&TestReportMapper::runTests();

&TestBalance::runTests();
&TestBalanceMapper::runTests();

&TestTransaction::runTests();
&TestTransactionMapper::runTests();

&TestMiscData::runTests();

&TestService::runTests();

&TestModelListeners::runTests();

&TestDatabase::runTests();

&done_testing();
