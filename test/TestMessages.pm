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
        my $messages = Messages->new();
        my $code = sub {1;};
        try {
            $messages->addListener(3, $code);
            ok(0, "bad listener event didn't cause failure");
        } catch {
            ok(1, "bad listener event correctly caused failure");
        };
        try {
            $messages->addListener([1,2,3], 14);
            ok(0, "bad code ref didn't cause failure");
        } catch {
            ok(1, "bad code ref correctly caused failure");
        };
        try {
            $messages->notify(3);
            ok(0, "bad event type notification didn't cause failure");
        } catch {
            ok(1, "bad event type notification correctly caused failure");
        };
        try {
            $messages->notify(['hi', 'bye', 'buy', 'by']);
            ok(0, "bad event didn't cause failure");
        } catch {
            ok(1, "bad event correctly caused failure");
        };
    };
    
    subtest 'add listener and notify' => sub {
        my $messages = Messages->new();
        my $i = 0;
        my $l = sub {$i++;};
        $messages->addListener("saveTransaction", $l);
        $messages->notify("saveTransaction");
        is($i, 1, "listener called once");
    };
    
    subtest 'remove listener' => sub {
        my $messages = Messages->new();
        my $i = 0;
        my $l = sub {$i++;};
        my $id = $messages->addListener("saveTransaction", $l);
        $messages->notify("saveTransaction");
        is($i, 1, "listener called once");
        $messages->removeListener($id);
        $messages->notify("saveTransaction");
        is($i, 1, "listener not called again");
        
        try {
            $messages->removeListener($id);
            ok(0, "listener removed twice");
        } catch {
            ok(1, "listener can only be removed once");
        };
    };
    
    subtest "valid events" => sub {
        my $messages = Messages->new();
        try {
            $messages->notify("saveTransaction");
            $messages->notify("updateTransaction");
            $messages->notify("deleteTransaction");
            $messages->notify("saveBalance");
            ok(1, "valid events");
        } catch {
            ok(0, "invalid event: $_");
        };
    };
    
    subtest 'transaction listeners' => sub {
        my $messages = Messages->new();
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
        
        $messages->addListener("deleteTransaction", $del);
        
        $messages->notify("deleteTransaction", "failure");
        is(0, $del{success});
        is(1, $del{failure});
        
        $messages->notify("deleteTransaction", "success");
        is(1, $del{success});
        is(1, $del{failure});
    };
}

1;
