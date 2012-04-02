use strict;
use warnings;

package TestService;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;
use Data::Dumper;

use lib '../src/model';
use Service;

use lib '../src/database';
use Database;


sub runTests {

    subtest 'service: transactions' => sub {
        try {
            my $service = Service->new(&Database::getDBConnection());
            my $first = {
                year    => 1492,
                month   => 3,
                day     => 18,
                account => "Credit card",
                type    => "General deposit",
                isreceiptconfirmed => 1,
                isbankconfirmed => 1,
                amount => 1,
                comment => "dunno"
            };
            my $lis = sub {
                my ($status) = @_;
                if($status eq "success") {
                    pass("saved transaction");
                } else {
                    fail("failed with status <$status>");
                }
            };
            $service->addListener("saveTransaction", $lis);
            $service->saveTransaction($first);
          
            my @ids = @{$service->getIDs()};
            DEBUG("got " . scalar(@ids) . ": " . Dumper(\@ids));
            # get the transaction with the highest id ... assume it's the one we just saved
            my $trans = $service->getTransaction($ids[$#ids]);
            
            isa_ok($trans, "Transaction");
            $trans->{amount} = 272.34;
            
            my %new;
            for my $key (keys %$trans) { # copy the key/value pairs over
                $new{$key} = $trans->{$key};
            }
            
            # update the one we're assuming to be the most recent
            $service->updateTransaction(Transaction->new(\%new));
            
            # get the one that we think we just updated
            my $saved = $service->getTransaction($ids[$#ids]);
            
            # check that it's the same as $trans
            is($saved->{amount}, $trans->{amount}, "amount");
            
            # can I test this?
#            $service->deleteTransaction($ids[$#ids]);
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
    subtest 'service: balances' => sub {
        try {
            my $service = Service->new(&Database::getDBConnection());
            my $dat = {
                year => 2012,
                month => 11,
                account => 'Savings',
                amount => 111.99
            };
            $service->replaceBalance($dat);
            
            my $bal = $service->getBalance(11, 2012, "Savings");
            is($bal->{amount}, $dat->{amount}, "amount of saved balance");
            
            $dat->{amount} = 14;
            # TODO is dat already blessed as a balance ?????
            $service->replaceBalance($dat);
            
            my $bal2 = $service->getBalance(11, 2012, "Savings");
            ok(14 == $bal2->{amount}, "amount of replaced balance");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
    subtest 'service: reports' => sub {
        try {
            my $service = Service->new(&Database::getDBConnection());
            my @reps = @{$service->getAvailableReports()};
            my $rep = $service->getReport($reps[0]);
            isa_ok($rep, "Report");
            ok(scalar(@{$rep->getRows()}) > 1, "report has rows");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
    
}


1;