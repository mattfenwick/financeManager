use strict;
use warnings;

package TestModelListeners;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Messages;
use Service;

use lib '../src/database';
use Database;


sub runTests {
    
    subtest 'transaction listeners' => sub {
        try {
            &Service::init(&Database::getDBConnection());
            my %del = (success => 0, failure => 0);
            my $del = sub {
                my ($status, @args) = @_;
                if($status eq "failure") {
                    $del{success}++;
                } elsif ($status eq "success") {
                    $del{failure}++;
                } else {
                    fail("invalid status: <$status>");
                }
            };
            # TODO does the dbc need to be set?
            &Service::deleteTransaction(1000000);
            pass($del{failure});
        } catch {
            ERROR($_);
            fail($_);
        };
    };
}

1;