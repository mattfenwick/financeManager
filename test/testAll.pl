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
use TestBalance;
use TestTransaction;
use TestMiscData;
use TestService;
use TestModelListeners;

try {
    &TestMessages::runTests();
} catch {
	ERROR("uncaught error from TestMessages suite: $_");
};

try {
    &TestReport::runTests();
} catch {
    ERROR("uncaught error from TestReport suite: $_");
};

try {
    &TestBalance::runTests();
} catch {
    ERROR("uncaught error from TestBalance suite: $_");
};

try {
    &TestTransaction::runTests();
} catch {
    ERROR("uncaught error from TestTransaction suite: $_");
};

try {
    &TestMiscData::runTests();
} catch {
    ERROR("uncaught error from TestMiscData suite: $_");
};

try {
    &TestService::runTests();
} catch {
    ERROR("uncaught error from TestService suite: $_");
};

try {
    &TestModelListeners::runTests();
} catch {
    ERROR("uncaught error from TestModelListeners suite: $_");
};

try {
    &TestDatabase::runTests();
} catch {
    ERROR("uncaught error from TestDatabase suite: $_");
};

&done_testing();
