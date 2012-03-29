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
        my $success = 0;
        try {
            my $tran = Transaction->new({
	            year => 1004,
	            account => "checking",
	            month => 7,
	            amount => -7.32
	        });
            $success = 1;
        };
        ok($success, "create valid transaction");
    };
    
    subtest 'create invalid transactions' => sub {
        try {
            Transaction->new(1,2,3,4);
            ok(0, "didn't catch bad parameters");
        } catch {
            ok(1, "caught bad constructor parameters")
        };
        
        try {
            Transaction->new({year => 1932});
            ok(0, "didn't catch missing keys");
        } catch {
            ok(1, "caught missing keys")
        };
        
        try {
            Transaction->new({
                year => 2004, month => 13, account => 22, amount => 77
            });
            ok(0, "didn't catch bad month");
        } catch {
            ok(1, "caught bad month")
        };
        
        try {
            Transaction->new({
                year => 2004, month => 3, account => 22, amount => 'abcd'
            });
            ok(0, "didn't catch string amount");
        } catch {
            ok(1, "caught string amount")
        };
        
        try {
            Transaction->new({
                year => 2004, month => 3, account => 22, amount => 7.345
            });
            ok(0, "didn't catch too many decimal places");
        } catch {
            ok(1, "caught too many many decimal places")
        };
        
        try {
            Transaction->new({
                year => 2004, month => 10, account => 32, amount => 77
            });
            ok(0, "didn't catch bad account");
        } catch {
            ok(1, "caught bad account")
        };
    };
    
    subtest 'database methods' => sub {    
        try {
            &Transaction::setDbh(&Database::getDBConnection());
	        my $trans = Transaction->new({
	            year   => 2007,
	            month  => 8,
	            account => "Checking",
	            amount => -18.11
	        });
	        &Transaction::save($trans);
	        my $loadedTrans = &Transaction::get(1);
	        $loadedTrans->{amount} = $loadedTrans->{amount} + 1;
	        &Transaction::update($loadedTrans);
	        &Transaction::delete(14); # TODO ??? how do I get the id ???
        } catch {
            ERROR("failed to save and load transaction: $_");
            ok(0, "failed to save and load transaction");
        };
    };
}

1;