use strict;
use warnings;

package TestService;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Service;

use lib '../src/database';
use Database;


sub runTests {

    subtest 'transactions' => sub {
        try {
            my $first = {
                date => 1,
                account => 1,
                type => 1,
                isReceiptConfirmed => 1,
                isBankConfirmed => 1,
                amount => 1,
                comment => 1
            };
            &Service::saveTransaction($first);
            my @ids = @{&Service::getIds()};
            # get the transaction with the highest id ... assume it's the one we just saved
            my $trans = &Service::getTransaction($ids[$#ids]);
            
            isa_ok($trans, "Transaction");
            $trans->{amount} = 272.34;
            
            my %new;
            for my $key (keys %$trans) { # copy the key/value pairs over
                $new{$key} = $trans->{$key};
            }
            
            # update the one we're assuming to be the most recent
            &Service::updateTransaction(\%new);
            
            # get the one that we think we just updated
            my $saved = &Service::getTransaction($ids[$#ids]);
            
            # check that it's the same as $trans
            is($saved->{amount}, $trans->{amount}, "amount");
            
            # can I test this?
            &Service::deleteTransaction($ids[$#ids]);
        } catch {
            fail("failed to C/R/U/D transaction: $_");
        };
    };
    
    subtest 'balances' => sub {
        try {
            my $dat = {
                year => 2012,
                month => 11,
                account => 'Savings',
                amount => 111.99
            };
            &Service::replaceBalance($dat);
            
            my $bal = &Service::getBalance(11, 2012, "Savings");
            is($bal->{amount}, $dat->{amount}, "amount of saved balance");
            
            $dat->{amount} = 14;
            # TODO is dat already blessed as a balance ?????
            &Service::replaceBalance($dat);
            
            my $bal2 = &Service::getBalance(11, 2012, "Savings");
            is(14, $bal2->{amount}, "amount of replaced balance");
        } catch {
            fail("failed to C/R/U balance: $_");
        };
    };
    
    subtest 'reports' => sub {
        try {
            my @reps = @{&Service::getAvailableReports()};
            my $rep = &Service::getReport($reps[0]);
            isa_ok($rep, "Report");
            ok(scalar(@{$rep->getRows()}) > 1, "report has rows");
        } catch {
            fail("failed to get report");
        };
    };
    
}


1;