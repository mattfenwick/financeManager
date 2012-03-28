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
        try {
            &Messages::addListener(3);
            ok(0, "bad listener didn't cause failure");
        } catch {
            ok(1, "bad listener correctly caused failure");
        };
        try {
            &Messages::addListener([1,2,3]);
            ok(0, "bad listener didn't cause failure");
        } catch {
            ok(1, "bad listener correctly caused failure");
        };
        try {
            &Messages::notify(3);
            ok(0, "bad event didn't cause failure");
        } catch {
            ok(1, "bad event correctly caused failure");
        };
        try {
            &Messages::notify(['hi', 'bye', 'buy', 'by']);
            ok(0, "bad event didn't cause failure");
        } catch {
            ok(1, "bad event correctly caused failure");
        };
    };
    
    subtest 'add listener' => sub {
        my $i = 0;
        my $l = sub {$i++;};
        &Messages::addListener($l);
        &Messages::notify({
            'category' => "transaction",
            'subcategory' => 'update',
            'status' => 'success'
        });
        is($i, 1, "listener called once");
    };
    
    subtest "valid event categories, subcategories, and statuses" => sub {
        my %event = (
            category => 'transaction',
            subcategory => 'save',
            status => 'success'
        );
        try {
            &Messages::notify(\%event);
            $event{category} = 'balance';
            &Messages::notify(\%event);
            $event{subcategory} = 'delete';
            &Messages::notify(\%event);
            $event{subcategory} = 'update';
            &Messages::notify(\%event);
            $event{status} = 'failure';
            &Messages::notify(\%event);
            ok(1, "valid event specifications");
        } catch {
            ok(0, "invalid event specification: $_");
        };
    };
    
    subtest "invalid event specifications cause exceptions" => sub {
        my %event = (
            category => 'balance',
            subcategory => 'save',
            status => 'success'
        );
        
        my $i = 0;
        try {
            &Messages::notify(\%event);
            $i = 1;
        };
        ok($i, "valid spec");
        
        $event{category} = "abcd";
        my $j = 1;
        try {
            &Messages::notify(\%event);
            $j = 0;
        };
        ok($j, "invalid category");
        
        $event{category} = 'transaction';
        my $k = 0;
        try {
            &Messages::notify(\%event);
            $k = 1;
        };
        ok($k, "valid spec");

        $event{subcategory} = 'blargh';
        my $l = 1;
        try {
            &Messages::notify(\%event);
            $l = 0;
        };
        ok($l, "invalid subcategory");
        
        $event{subcategory} = 'delete';
        my $m = 0;
        try {
            &Messages::notify(\%event);
            $m = 1;
        };
        ok($m, "valid spec");
        
        $event{status} = 'pause';
        my $n = 1;
        try {
            &Messages::notify(\%event);
            $n = 0;
        };
        ok($n, "invalid status");
    };
    
    subtest 'remove listener' => sub {
        my $i = 0;
        my $l = sub {$i++;};
        
        my $event = {
            category => 'transaction',
            subcategory => 'update',
            status => 'success'
        };
        
        my $id = &Messages::addListener($l);
        &Messages::notify($event);
        
        is($i, 1, "listener notified");
        
        &Messages::removeListener($id);
        &Messages::notify($event);
        
        is($i, 1, "listener removed and not notified");
        
        try {
            &Messages::removeListener($id);
            ok(0, "listener removed twice");
        } catch {
            ok(1, "listener can only be removed once");
        };
    };
}

1;
