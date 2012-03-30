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
                date    => '2011-8-19',
	            account => "Checking",
	            amount  => 7.32,
	            isReceiptConfirmed => 0,
	            isBankConfirmed    => 1,
	            type    => 'General withdrawal',
	            comment => 'abcd'
	        });
            ok(1, "create valid transaction");
        } catch {
            fail("failed to create transaction: $_");
        };
    };
    
    subtest 'create invalid transactions' => sub {
        try {
            Transaction->new(1,2,3,4);
            ok(0, "didn't catch bad parameters");
        } catch {
            ok(1, "caught bad constructor parameters: $_")
        };
        
        try {
            Transaction->new({date => '1932-2-4'});
            ok(0, "didn't catch missing keys");
        } catch {
            ok(1, "caught missing keys")
        };
        
        try {
            Transaction->new({
                date => '2004-13-1', 
                account => 'Savings', 
                amount => 77,
                isReceiptConfirmed => 0,
                isBankConfirmed    => 1,
                type    => 'General withdrawal',
                comment => 'abcd'
            });
            ok(0, "didn't catch bad date");
        } catch {
            ok(1, "caught bad date <$_>")
        };
    };
}

1;