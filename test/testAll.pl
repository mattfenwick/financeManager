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

#use TestIntegration; # runs at compile time ???
use TestMessages;
use TestReport;
use TestBalance;


try {
#    &TestMessages::runTests();
} catch {
	ERROR("uncaught error from TestMessages suite: $_");
};

try {
#    &TestReport::runTests();
} catch {
    ERROR("uncaught error from TestReport suite: $_");
};

try {
    &TestBalance::runTests();
} catch {
    ERROR("uncaught error from TestBalance suite: $_");
};

&done_testing();
