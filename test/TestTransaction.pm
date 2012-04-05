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
            WARN("running TestTransaction");
            # all fields but id
            my $tran1 = Transaction->new({
                date            => '2011-8-19',
                purchasedate    => '2011-08-09',
                savedate        => '2011-6-30',
	            account         => "Checking",
	            amount          => 7.32,
	            isreceiptconfirmed => 0,
	            isbankconfirmed    => 1,
	            type            => 'General withdrawal',
	            comment         => 'abcd'
	        });
            pass("create valid transaction 1");
            
            # all but savedate
            my $tran2 = Transaction->new({
                date            => '2011-8-19',
                purchasedate    => '2012-4-0', # yes, 0 is okay for "day"
                account         => "Checking",
                amount          => 7.32,
                isreceiptconfirmed => 0,
                isbankconfirmed    => 1,
                type            => 'General withdrawal',
                comment         => 'abcd'
            });
            pass("create valid transaction 2");
            
            # all fields populated
            my $tran3 = Transaction->new({
                id              => 18,
                date            => '2010-08-3',
                purchasedate    => '2013-12-22',
                savedate        => '2008-4-30',
                account         => "Checking",
                amount          => 7.32,
                isreceiptconfirmed => 0,
                isbankconfirmed    => 1,
                type            => 'General withdrawal',
                comment         => ''
            });
            pass("create valid transaction 3");
        } catch {
            fail("failed to create transaction: $_");
        };
    };
    
    subtest 'create invalid transactions' => sub {
        try {
            Transaction->new(1,2,3,4);
            fail("didn't catch bad parameters");
        } catch {
            pass("caught bad constructor parameters: $_")
        };
        
        try {
            Transaction->new({date => '1932-2-4'});
            fail("didn't catch missing keys");
        } catch {
            pass("caught missing keys: $_")
        };
        
        try {
            Transaction->new({
                date            => '2004-13-1',
                purchasedate    => '2012-3-11',
                account         => 'Savings', 
                amount          => 22.12,
                isreceiptconfirmed => 0,
                isbankconfirmed    => 1,
                type            => 'General withdrawal',
                comment         => 'jkl'
            });
            fail("didn't catch bad month");
        } catch {
            pass("caught bad month: $_")
        };
    };
}

1;