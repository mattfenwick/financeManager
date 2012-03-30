use strict;
use warnings;

package TestTransactionMapper;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Transaction;

use lib '../src/database';
use Database;


sub runTests {
    
    subtest 'database methods' => sub {    
        try {
            my $mapper = TransactionMapper->new(&Database::getDBConnection());
	        my $trans = Transaction->new({
                date => '2004-13-1', 
                account => 'Savings', 
                amount => 77,
                isReceiptConfirmed => 0,
                isBankConfirmed    => 1,
                type    => 'General withdrawal',
                comment => 'abcd'
	        });
	        my $result = $mapper->save($trans);
	        is(1, $result, "saved transaction");
	        my $loadedTrans = $mapper->get(1);
	        $loadedTrans->{amount} = $loadedTrans->{amount} + 1;
	        $mapper->update($loadedTrans);
	        $mapper->delete(14); # TODO ??? how do I get the id ???
        } catch {
            my $message = "failed to save and load transaction: $_";
            ERROR($message);
            fail($message);
        };
    };
    
    subtest 'get non-existent transaction' => sub {
        my $mapper = TransactionMapper->new(&Database::getDBConnection());
        my $trans = $mapper->get(1000000);
        ok($trans, "$trans");
        isa_ok($trans, "Transaction");
    };
    
}

1;
