
use strict;
use warnings;
use Test::More;
use Try::Tiny;
use lib '../src';
use lib '../src/gui';
use lib '../src/model';
use Log::Log4perl qw(:easy);

use Model;
use Database;
use FinanceGUI;

BEGIN {
    Log::Log4perl->easy_init({
        level   => $DEBUG,
        file    => ">>testLog.txt",
        layout  => '%p  %F{1}-%L-%M: (%d) %m%n' 
    });
}


subtest 'model listeners' => sub {
    my $model = Model->new();
    $model->addListener("saveTrans",   sub {});
    $model->addListener("saveBalance", sub {});
    $model->addListener("saveBalance", sub {});
    is(scalar(@{$model->{listeners}->{saveTrans}}),    1, "number of saveTrans listeners");
    is(scalar(@{$model->{listeners}->{saveBalance}}),  2, "number of saveBalance listeners");
    is(scalar(@{$model->{listeners}->{editTrans}}),    0, "number of editTrans listeners");
    is(scalar(@{$model->{listeners}->{deleteTrans}}),  0, "number of deleteTrans listeners");
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
    	is($i, 1, "bad code ref caused expected exception");
    }
    
    my $j = 0;
    my $c = sub {$j += 14;};
    $model->addListener("saveBalance", $c);
    $model->_notify("saveBalance");
    is($j, 14, "saveBalance listener called once");
    
    my ($q, $r) = (0, 0);
    my $d = sub {$q += $_[0]; $r += $_[1];};
    $model->addListener("editTrans", $d);
    $model->_notify("editTrans", 75, 82);
    is($q, 75, "editTrans listener called and first argument passed");
    is($r, 82, "editTrans listener called and second argument passed");
};

subtest 'database connection and simple query' => sub {
	my $dbh = Database::getDBConnection();
	my $sth = $dbh->prepare("select * from transactions");
	$sth->execute();
	my $result = $sth->fetchall_arrayref();
	is(ref($result), "ARRAY", "query result type");
	ok(scalar(@$result) > 50, "number of rows");
};

#subtest 'initialize gui' => sub { # fails because Model has to hit up the database ... need to mock the Model
#	my $model = Model->new();
#	my $gui = FinanceGUI->new($model);
#	ok(1, "no exception thrown when initializing gui")
#};


1;