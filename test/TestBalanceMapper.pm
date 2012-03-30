use strict;
use warnings;

package TestBalanceMapper;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Balance;
use BalanceMapper;

use lib '../src/database';
use Database;


sub runTests {
    
    subtest 'database methods' => sub {    
        try {
            my $mapper = BalanceMapper->new(&Database::getDBConnection());
	        my $bal = Balance->new({
	            year   => 2007,
	            month  => 8,
	            account => "Checking",
	            amount => -18.11
	        });
	        
	        INFO("... did NOT replace balance");
	        $mapper->replace($bal);
	        my $loadedBal = $mapper->get(8, 2007, "Checking");
	        
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