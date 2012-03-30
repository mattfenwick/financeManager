use strict;
use warnings;

package TestTransaction;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Transaction;

use lib '../src/database';
use Database;


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
    
    subtest 'database methods' => sub {    
        try {
            &Transaction::setDbh(&Database::getDBConnection());
	        my $trans = Transaction->new({
                date => '2004-13-1', 
                account => 'Savings', 
                amount => 77,
                isReceiptConfirmed => 0,
                isBankConfirmed    => 1,
                type    => 'General withdrawal',
                comment => 'abcd'
	        });
	        my $result = &Transaction::save($trans);
	        is(1, $result, "saved transaction");
	        my $loadedTrans = &Transaction::get(1);
	        $loadedTrans->{amount} = $loadedTrans->{amount} + 1;
	        &Transaction::update($loadedTrans);
	        &Transaction::delete(14); # TODO ??? how do I get the id ???
        } catch {
            my $message = "failed to save and load transaction: $_";
            ERROR($message);
            fail($message);
        };
    };
    
    subtest 'get non-existent transaction' => sub {
        my $trans = &Transaction::get(1000000);
        ok($trans, "$trans");
        isa_ok($trans, "Transaction");
    };
}

1;