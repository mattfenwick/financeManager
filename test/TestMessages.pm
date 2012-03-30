use strict;
use warnings;

package TestMessages;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/model';
use Messages;


sub runTests {
    
    subtest 'pass in junk listeners and events' => sub {
        my $code = sub {1;};
        try {
            &Messages::addListener(3, $code);
            ok(0, "bad listener event didn't cause failure");
        } catch {
            ok(1, "bad listener event correctly caused failure");
        };
        try {
            &Messages::addListener([1,2,3], 14);
            ok(0, "bad code ref didn't cause failure");
        } catch {
            ok(1, "bad code ref correctly caused failure");
        };
        try {
            &Messages::notify(3);
            ok(0, "bad event type notification didn't cause failure");
        } catch {
            ok(1, "bad event type notification correctly caused failure");
        };
        try {
            &Messages::notify(['hi', 'bye', 'buy', 'by']);
            ok(0, "bad event didn't cause failure");
        } catch {
            ok(1, "bad event correctly caused failure");
        };
    };
    
    subtest 'add listener and notify' => sub {
        my $i = 0;
        my $l = sub {$i++;};
        &Messages::addListener("saveTransaction", $l);
        &Messages::notify("saveTransaction");
        is($i, 1, "listener called once");
    };
    
    subtest 'remove listener' => sub {
        my $i = 0;
        my $l = sub {$i++;};
        my $id = &Messages::addListener("saveTransaction", $l);
        &Messages::notify("saveTransaction");
        is($i, 1, "listener called once");
        &Messages::removeListener($id);
        &Messages::notify("saveTransaction");
        is($i, 1, "listener not called again");
        
        try {
            &Messages::removeListener($id);
            ok(0, "listener removed twice");
        } catch {
            ok(1, "listener can only be removed once");
        };
    };
    
    subtest "valid events" => sub {
        try {
            &Messages::notify("saveTransaction");
            &Messages::notify("updateTransaction");
            &Messages::notify("deleteTransaction");
            &Messages::notify("saveBalance");
            ok(1, "valid events");
        } catch {
            ok(0, "invalid event: $_");
        };
    };
    
    subtest 'transaction listeners' => sub {
        my %del = (success => 0, failure => 0);
        my $del = sub {
            my ($status, @args) = @_;
            if($status eq "failure") {
                $del{failure}++;
            } elsif ($status eq "success") {
                $del{success}++;
            } else {
                fail("invalid status: <$status>");
            }
        };
        
        &Messages::addListener("deleteTransaction", $del);
        
        &Messages::notify("deleteTransaction", "failure");
        is(0, $del{success});
        is(1, $del{failure});
        
        &Messages::notify("deleteTransaction", "success");
        is(1, $del{success});
        is(1, $del{failure});
    };
}

1;
