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
        my %del = (success => 0, failure => 0);
        my $del = sub {
            my ($event) = @_;
            if($event->{category} eq "transaction" && 
                    $event->{subcategory} eq "delete") {
                if($event->{status} eq "success") {
                    $del{success}++;
                } elsif ($event->{status} eq "failure") {
                    $del{failure}++;
                }
            }
        };
    };
}

1;