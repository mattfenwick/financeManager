use strict;
use warnings;

package Service;

use Transaction;
use TransactionMapper;

use Balance;
use BalanceMapper;

use Report;
use ReportMapper;

use MiscData;
use Messages;



my ($balanceMapper, $transactionMapper, $reportMapper, $miscData);

sub init {
    my ($dbh) = @_;
    $balanceMapper     = BalanceMapper->new($dbh);
    $transactionMapper = TransactionMapper->new($dbh);
    $reportMapper      = ReportMapper->new($dbh);
    $miscData          = MiscData->new($dbh);
}

####################################################
# domain objects

##### transactions

sub saveTransaction {
    INFO("saving transaction:  args are " . Dumper(\@_) );
    my $trans = Transaction->new(@_);
    my $result = $transactionMapper->save($trans);
    if($result == 1) {
        INFO("save transaction succeeded, result:  <$result>");
        &Messages::notify("saveTransaction", "success");
    } else {
        ERROR("save transaction failed, result: <$result>");
        &Messages::notify("saveTransaction", "failure", $result);
    }
}


sub getTransaction {
    my ($id) = @_;
    INFO("attempting to fetch transaction of id <$id>");
    my $trans = $transactionMapper->get($id);
    if($trans) {
        INFO("transaction result: " . Dumper($trans) );
    } else {
        ERROR("no transaction found");
    }
    return $trans;
}


sub deleteTransaction {
    my ($id) = @_;
    INFO("attempting to delete transaction <$id>");
    my $result = $transactionMapper->delete($id);
    if($result == 1) {
        INFO("deleted transaction");
        &Messages::notify("deleteTransaction", "success");
    } else {
        ERROR("could not delete transaction <$id>: $result");
        &Messages::notify("deleteTransaction", "failure", $result);
    }
}


sub updateTransaction {
    INFO("updating transaction, args are:  " . Dumper(\@_));
    my $trans = Transaction->new(@_);
    my $result = $transactionMapper->update($trans);
    if($result == 1) {
        INFO("update transaction succeeded, result:  <$result>");
        &Messages::notify("updateTransaction", "success");
    } else {
        ERROR("update transaction failed, result: <$result>");
        &Messages::notify("updateTransaction", "failure", $result);
    }
}


####### balances

sub replaceBalance {
    INFO("setting end of month balance, args are: " . Dumper(\@_) );
    my $bal = Balance->new(@_);
    my $result = $balanceMapper->replace($bal);  
    # 3 modes: 
    #   1. new row, 
    #   2. overwrite existing row with new values.   
    #   anything else:  failure, 
    if($result == 1 || $result == 2) {
        INFO("save balance succeeded, result:  <$result>");
        &Messages::notify("saveBalance", "success");
    } else {
        INFO("save balance failed, result: <$result>");
        &Messages::notify("saveBalance", "failure");
    }
}


sub getBalance {
    INFO("setting end of month balance, args are: " . Dumper(\@_) );
    my $bal = $balanceMapper->get(@_);
    if($bal) {
        INFO("balance result: " . Dumper($bal));
    } else {
        INFO("no balance found");
    }
    return $bal;
}


####### reports

sub getReport {
    INFO("getting report, args are: " . Dumper(\@_));
    my $rep = $reportMapper->getReport(@_);
    if($rep) {
        INFO("report result: " . scalar($rep->getRows()) . " rows");
    } else {
        ERROR("no report found");
    }
    return $rep;
}


###########################################################
# "columns"

sub getMonths {
    return [$miscData->getColumn('months')];
}


sub getYears {
    return [$miscData->getColumn('years')];
}


sub getDays {
    return [$miscData->getColumns('days')];
}


sub getAccounts {
    return [$miscData->getColumn('accounts')];
}


sub getTransactionTypes {
    return [$miscData->getColumn('types')];
}


sub getComments {
    my @comments = $miscData->getColumn('comments');
    return [sort {lc $a cmp lc $b} @comments];
}


sub getIDs {
    my @ids = $miscData->getColumn('ids');
    return [sort {$a <=> $b} @ids];
}


sub getAvailableReports {
    return $reportMapper->getAvailableReports();
}

######################################################
# scalars

sub getWebAddress {
    return $miscData->getScalar('webAddress');
}


sub getVersion {
    return $miscData->getScalar('version');
}


sub getCurrentYear {
    return $miscData->getScalar('currentYear');
}


1;