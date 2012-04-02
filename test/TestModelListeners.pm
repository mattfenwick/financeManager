use strict;
use warnings;

package TestModelListeners;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;
use Data::Dumper;

use lib '../src/model';
use Messages;
use Service;

use lib '../src/database';
use Database;


sub runTests {
    
    subtest 'delete transaction listeners' => sub {
        try {
            my $service = Service->new(&Database::getDBConnection());
            my %del = (success => 0, failure => 0);
            my $del = sub {
                my ($status, @args) = @_;
                if($status eq "success") {
                    $del{success}++;
                } elsif ($status eq "failure") {
                    $del{failure}++;
                } else {
                    fail("invalid status: <$status>");
                }
            };
            $service->addListener("deleteTransaction", $del);
            $service->addListener("deleteTransaction", $del);
            $service->deleteTransaction(1435345);
            is(2, $del{failure}, "failed to delete non-existent transaction");
        } catch {
            ERROR($_);
            fail($_);
        };
    };
}

1;