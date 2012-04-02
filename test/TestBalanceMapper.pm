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
    
    subtest 'balance mapper database methods' => sub {    
        try {
            my $dbh = &Database::getDBConnection();
            # set up the environment ...
            $dbh->do('delete from endofmonthbalances where yearid = 2007 and
                monthid = 8 and account = "Checking" limit 1');
            my $mapper = BalanceMapper->new($dbh);
            my $init = $mapper->get(8, 2007, "Checking");
            ok(!$init, "did not find balance");
            
	        my $bal = Balance->new({
	            year   => 2007,
	            month  => 8,
	            account => "Checking",
	            amount => -18.11
	        });
	        
	        INFO("... did NOT replace balance yet ...");
	        my $res = $mapper->replace($bal);
	        is($res, 1, "one row affected on new insert");
	        
	        my $loadedBal = $mapper->get(8, 2007, "Checking");
	        
	        is($bal->{amount},  $loadedBal->{amount},  "correct amount");
            is($bal->{year},    $loadedBal->{year},    "correct year");
            is($bal->{month},   $loadedBal->{month},   "correct month");
            is($bal->{account}, $loadedBal->{account}, "correct account");
            
            $bal->{amount} = 32.36;
            $res = $mapper->replace($bal);
            is($res, 2, "two rows affected on replace");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
}

1;