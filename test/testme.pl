
BEGIN {push(@INC, '../src')}; # is there a better way to get this file to see the other files?

use strict;
use warnings;
use Test::More;
use Try::Tiny;

use Model;

subtest 'model listeners' => sub {
    my $model = Model->new();
    $model->addListener("saveTrans",   sub {});
    $model->addListener("saveBalance", sub {});
    $model->addListener("saveBalance", sub {});
    is(scalar(@{$model->{listeners}->{saveTrans}}),   1, "number of saveTrans listeners");
    is(scalar(@{$model->{listeners}->{saveBalance}}), 2, "number of saveBalance listeners");
    is(scalar(@{$model->{listeners}->{getReport}}),   0, "number of getReport listeners");
};


subtest 'listeners:  bad events' => sub {
    my $model = Model->new();
    my $i = 0;
    try {
        $model->addListener("saveTrans2", sub {});
        $i++;
        ok(0, "bad event type should have thrown exception");
    } catch {
        $i++;
        ok(1, "bad event type caused exception");
    };
    is($i, 1, "only execute one branch");
};

subtest 'listeners: code refs' => sub {
    my $model = Model->new();
    my $i = 0;
    try {
        $model->addListener("saveTrans", sub {}); # make sure that the event type is fine
        $i++;
        $model->addListener("saveTrans");
    } catch {
    	is($i, 1, "bad code ref caused exception");
    }
    
    my $j = 0;
    my $c = sub {$j += 14;};
    $model->addListener("saveBalance", $c);
    $model->_notify("saveBalance");
    is($j, 14, "saveBalance listener called once");
    
    my ($q, $r) = (0, 0);
    my $d = sub {$q += $_[0]; $r += $_[1];};
    $model->addListener("newTransIds", $d);
    $model->_notify("newTransIds", 75, 82);
    is($q, 75, "newIds listener called and first argument passed");
    is($r, 82, "newIds listener called and second argument passed");
};

&done_testing();
