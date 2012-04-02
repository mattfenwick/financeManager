use strict;
use warnings;

package TestTransactionMapper;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;
use Data::Dumper;

use lib '../src/model';
use Transaction;

use lib '../src/database';
use Database;


sub runTests {
    
    subtest 'save transaction' => sub {    
        try {
            my $mapper = TransactionMapper->new(&Database::getDBConnection());
	        my $trans = Transaction->new({
                year    => 2004,
                month   => 11,
                day     => 1, 
                account => 'Savings', 
                amount => 77,
                isreceiptconfirmed => 0,
                isbankconfirmed    => 1,
                type    => 'General withdrawal',
                comment => 'abcd'
	        });
	        my $result = $mapper->save($trans);
	        is(1, $result, "saved transaction");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
    subtest 'delete transaction' => sub {
        try {
            my $dbh = &Database::getDBConnection();
            $dbh->do('insert into transactions 
                (id, `date`, comment, amount, type, 
                    account, isreceiptconfirmed, isbankconfirmed) 
                values 
                (2000000, "2011-1-1", "hi", 1, "General withdrawal",
                    "Checking", 1, 0);');
            my $mapper = TransactionMapper->new($dbh);
            my $res = $mapper->delete(2000000);
            is($res, 1, "row properly deleted");
        } catch {
            ERROR($_);
            fail($_);            
        };
    };
    
    subtest 'get transaction' => sub {
        try {
            my $mapper = TransactionMapper->new(&Database::getDBConnection());
            my $trans = $mapper->get(4);
            isa_ok($trans, "Transaction");
        } catch {
            ERROR($_);
            fail($_);
        };        
    };
    
    subtest 'update transaction' => sub {
        try {
            my $dbh = &Database::getDBConnection();
            my $mapper = TransactionMapper->new($dbh);
            my $loadedTrans = $mapper->get(1);
            isa_ok($loadedTrans, "Transaction");
            INFO("got transaction: " . Dumper($loadedTrans));
            my $res = $mapper->update($loadedTrans);
            is($res, 1, "updated one row");
        } catch {
            ERROR($_);
            fail($_);            
        };
    };
    
    subtest 'get non-existent transaction' => sub {
        try {
            my $mapper = TransactionMapper->new(&Database::getDBConnection());
            my $trans = $mapper->get(1000000);
            isnt($trans, "should not have transaction");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
}

1;
