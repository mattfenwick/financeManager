use strict;
use warnings;

package Service;
use Transaction;
use Balance;
use MiscData;
use Report;
use Messages;


####################################################
# domain objects

##### transactions

sub saveTransaction {
    INFO("saving transaction:  args are " . Dumper(\@_) );
    my $trans = Transaction->new(@_);
    my $result = &Transaction::save($trans);
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
    my $trans = &Transaction::get($id);
    if($trans) {
        INFO("transaction result: " . Dumper($trans) );
    } else {
        INFO("no transaction found");
    }
    return $trans;
}


sub deleteTransaction {
    my ($id) = @_;
    INFO("attempting to delete transaction <$id>");
    my $result = &Transaction::delete($id);
    if($result == 1) {
        INFO("deleted transaction");
        &Messages::notify("deleteTransaction", "success");
    } else {
        ERROR("could not delete transaction <$id>: $result");
        &Messages::notify("deleteTransaction", "failure", $result);
    }
}


sub updateTransaction {
    my $trans = Transaction->new(@_);
    INFO("updating transaction:  " . Dumper(\@_));
    my $result = &Transaction::update($trans);
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
    my $bal = Balance->new(@_);
    &Balance::replace($bal);
}


sub getBalance {
    &Balance::get(@_);
}


####### reports

sub getReport {
    return &Report::getReport(@_);
}


###########################################################
# "columns"

sub getMonths {
    return [&MiscData::getColumn('months')];
}


sub getYears {
    return [&MiscData::getColumn('years')];
}


sub getDays {
    return [&MiscData::getColumns('days')];
}


sub getAccounts {
    return [&MiscData::getColumn('accounts')];
}


sub getTransactionTypes {
    return [&MiscData::getColumn('types')];
}


sub getComments {
    my @comments = &MiscData::getColumn('comments');
    return [sort {lc $a cmp lc $b} @comments];
}


sub getIDs {
    my @ids = &MiscData::getColumn('ids');
    return [sort {$a <=> $b} @ids];
}


sub getAvailableReports {
    return &Report::getAvailableReports();
}

######################################################
# scalars

sub getWebAddress {
    return &MiscData::getScalar('webAddress');
}


sub getVersion {
    return &MiscData::getScalar('version');
}


sub getCurrentYear {
    return &MiscData::getScalar('currentYear');
}


1;