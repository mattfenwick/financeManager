use strict;
use warnings;

package TestTransaction;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Transaction;



sub runTests {

    subtest 'create valid transactions' => sub {
        try {
            my $tran = Transaction->new({
                year    => 2011,
                month   => 8,
                day     => 19,
	            account => "Checking",
	            amount  => 7.32,
	            isReceiptConfirmed => 0,
	            isBankConfirmed    => 1,
	            type    => 'General withdrawal',
	            comment => 'abcd'
	        });
            pass("create valid transaction");
        } catch {
            fail("failed to create transaction: $_");
        };
    };
    
    subtest 'create invalid transactions' => sub {
        try {
            Transaction->new(1,2,3,4);
            fail("didn't catch bad parameters");
        } catch {
            ok(1, "caught bad constructor parameters: $_")
        };
        
        try {
            Transaction->new({date => '1932-2-4'});
            fail("didn't catch missing keys");
        } catch {
            ok(1, "caught missing keys: $_")
        };
        
        try {
            Transaction->new({
                year    => 2004,
                month   => 13,
                day     => 1, 
                account => 'Savings', 
                amount  => 77,
                isReceiptConfirmed => 0,
                isBankConfirmed    => 1,
                type    => 'General withdrawal',
                comment => 'abcd'
            });
            fail("didn't catch bad month");
        } catch {
            ok(1, "caught bad month: $_")
        };
    };
}

1;