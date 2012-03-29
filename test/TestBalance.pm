use strict;
use warnings;

package TestBalance;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Balance;
use MiscData;

use lib '../src/database';
use Database;


sub runTests {

    subtest 'create valid balances' => sub {
        my $success = 0;
        try {
            &MiscData::setDbh(&Database::getDBConnection());
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
            ok(0, "didn't catch bad parameters");
        } catch {
            ok(1, "caught bad constructor parameters")
        };
        
        try {
            Balance->new({year => 1932});
            ok(0, "didn't catch missing keys");
        } catch {
            ok(1, "caught missing keys")
        };
        
        try {
            Balance->new({
                year => 2004, month => 13, account => 22, amount => 77
            });
            ok(0, "didn't catch bad month");
        } catch {
            ok(1, "caught bad month")
        };
        
        try {
            Balance->new({
                year => 2004, month => 3, account => 22, amount => 'abcd'
            });
            ok(0, "didn't catch string amount");
        } catch {
            ok(1, "caught string amount")
        };
        
        try {
            Balance->new({
                year => 2004, month => 3, account => 22, amount => 7.345
            });
            ok(0, "didn't catch too many decimal places");
        } catch {
            ok(1, "caught too many many decimal places")
        };
        
        try {
            Balance->new({
                year => 2004, month => 10, account => 32, amount => 77
            });
            ok(0, "didn't catch bad account");
        } catch {
            ok(1, "caught bad account")
        };
    };
    
    subtest 'database methods' => sub {    
        try {
            &Balance::setDbh(&Database::getDBConnection());
	        my $bal = Balance->new({
	            year   => 2007,
	            month  => 8,
	            account => "Checking",
	            amount => -18.11
	        });
	        INFO("... did NOT replace balance");
	        &Balance::replace($bal);
	        my $loadedBal = &Balance::get(8, 2007, "Checking");
	        is($bal->{amount},  $loadedBal->{amount},  "correct amount");
            is($bal->{year},    $loadedBal->{year},    "correct year");
            is($bal->{month},   $loadedBal->{month},   "correct month");
            is($bal->{account}, $loadedBal->{account}, "correct account");
        } catch {
            ERROR("failed to save and load balance: $_");
            ok(0, "failed to save and load balance");
        };
    };
}

1;