use strict;
use warnings;

package TestBalance;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Balance;


sub runTests {

    subtest 'create valid balance' => sub {
        my $success = 0;
        try {
            my $bal = Balance->new({
	            year => 1004,
	            account => "Checking",
	            month => 7,
	            amount => -7.32
	        });
            $success = 1;
        } catch {
            ERROR("couldn't create balance: $_");
        };
        ok($success, "create valid balance");
    };
    
    subtest 'create invalid balances' => sub {
        try {
            Balance->new(1,2,3,4);
            fail("didn't catch bad parameters");
        } catch {
            pass("caught bad constructor parameters")
        };
        
        try {
            Balance->new({year => 1932});
            fail("didn't catch missing keys");
        } catch {
            pass("caught missing keys")
        };
        
        try {
            Balance->new({
                year => 2004, month => 13, account => 22, amount => 77
            });
            fail("didn't catch bad month");
        } catch {
            pass("caught bad month")
        };
        
        try {
            Balance->new({
                year => 2004, month => 3, account => 22, amount => 'abcd'
            });
            fail("didn't catch string amount");
        } catch {
            pass("caught string amount")
        };
        
        try {
            Balance->new({
                year => 2004, month => 3, account => 22, amount => 7.345
            });
            fail("didn't catch too many decimal places");
        } catch {
            pass("caught too many many decimal places")
        };

# commented out because:
#   can't figure out how to account values without using the database
#         
#        try {
#            Balance->new({
#                year => 2004, month => 10, account => 32, amount => 77
#            });
#            fail("didn't catch bad account");
#        } catch {
#            pass("caught bad account")
#        };
    };
}

1;