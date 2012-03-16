
use strict;
use warnings;
use Test::More;
use Try::Tiny;
use lib '../src';
use lib '../src/gui';
use lib '../src/model';
use Log::Log4perl qw(:easy);

use Model;
use MockDB;

BEGIN {
    Log::Log4perl->easy_init({
        level   => $DEBUG,
        file    => ">>testLog.txt",
        layout  => '%p  %F{1}-%L-%M: (%d) %m%n' 
    });
}


subtest 'saveTrans listeners' => sub {
    my $query = 'insert into transactions 
                (`date`, comment, amount, type, account, isReceiptConfirmed, isBankConfirmed)
                values(?, ?, ?, ?, ?, ?, ?)';
    my ($dbh) = MockDB->new({$query => 1});
    my ($model) = Model->new($dbh);
    my $res = "not called";
    my $oth = "not called";
    $model->addListener("saveTrans", sub {
        my ($status) = @_;
        $res = $status;
    });
    $model->addListener("saveTrans", sub {
        my ($s) = @_;
        $oth = $s;
    });
    $model->addTransaction({'some keys' => 'and values'});
    is($res, "success", "listener to save event: success expected");
    is($oth, "success", "listener to save event: success expected");

    $dbh->{queryResults}->{$query} = 0;

    $model->addTransaction({'some keys' => 'and values'});
    is($res, "failure", "listener to save event: failure expected");
    is($oth, "failure", "listener to save event: failure expected");
};


subtest 'editTrans listeners' => sub {
    my $query = '
        update transactions set
            `date` = ?, 
            comment = ?, 
            amount = ?, 
            account = ?, 
            isreceiptconfirmed = ?, 
            isbankconfirmed = ?,
            type = ?
        where id = ?';
    my ($dbh) = MockDB->new({$query => 1});
    my ($model) = Model->new($dbh);
    my $res = "not called";
    my $oth = "not called";
    $model->addListener("editTrans", sub {
        my ($status) = @_;
        $res = $status;
    });
    $model->addListener("editTrans", sub {
        my ($s) = @_;
        $oth = $s;
    });
    $model->updateTransaction({'some keys' => 'and values'});
    is($res, "success", "listener to save event: success expected");
    is($oth, "success", "listener to save event: success expected");

    $dbh->{queryResults}->{$query} = 0;

    $model->updateTransaction({'some keys' => 'and values'});
    is($res, "failure", "listener to save event: failure expected");
    is($oth, "failure", "listener to save event: failure expected");
};


subtest 'editTrans listeners' => sub {
    my $query = '
        delete from transactions where id = ? limit 1';
    my ($dbh) = MockDB->new({$query => 1});
    my ($model) = Model->new($dbh);
    my $res = "not called";
    my $oth = "not called";
    $model->addListener("deleteTrans", sub {
        my ($status) = @_;
        $res = $status;
    });
    $model->addListener("deleteTrans", sub {
        my ($s) = @_;
        $oth = $s;
    });
    $model->deleteTransaction({'some keys' => 'and values'});
    is($res, "success", "listener to save event: success expected");
    is($oth, "success", "listener to save event: success expected");

    $dbh->{queryResults}->{$query} = 0;

    $model->deleteTransaction({'some keys' => 'and values'});
    is($res, "failure", "listener to save event: failure expected");
    is($oth, "failure", "listener to save event: failure expected");
};


subtest 'getTrans' => sub {
    my $query = '
        select 
            *, 
            year(`date`) as year, 
            month(`date`) as month, 
            day(`date`) as day 
        from transactions where id = ?';
    my ($dbh) = MockDB->new({$query => 1, heading => ['a', 'b', 'c']});
    my ($model) = Model->new($dbh);
    my $trans = $model->getTransaction(13);
    
    ok($trans, "get transaction");
    
    
    my ($dbh2) = MockDB->new({$query => undef, heading => ['a', 'b', 'c']});
    $model->{dbh} = $dbh2;
    my $t2 = $model->getTransaction(16);
    
    is($t2, undef, "second transaction");
};


1;