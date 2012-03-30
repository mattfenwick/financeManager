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

use Log::Log4perl qw(:easy);



sub new {
    my ($class, $dbh) = @_;
    my $self = {
        balanceMapper     => BalanceMapper->new($dbh),
        transactionMapper => TransactionMapper->new($dbh),
        reportMapper      => ReportMapper->new($dbh),
        miscData          => MiscData->new($dbh)
    };
    bless($self, $class);
    return $self;
}

####################################################
# domain objects

##### transactions

sub saveTransaction {
    my ($self, $hashref) = @_;
    INFO("saving transaction:  args are " . Dumper($hashref) );
    my $trans = Transaction->new($hashref);
    my $result = $self->{transactionMapper}->save($trans);
    if($result == 1) {
        INFO("save transaction succeeded, result:  <$result>");
        &Messages::notify("saveTransaction", "success");
    } else {
        ERROR("save transaction failed, result: <$result>");
        &Messages::notify("saveTransaction", "failure", $result);
    }
}


sub getTransaction {
    my ($self, $id) = @_;
    INFO("attempting to fetch transaction of id <$id>");
    my $trans = $self->{transactionMapper}->get($id);
    if($trans) {
        INFO("transaction result: " . Dumper($trans) );
    } else {
        ERROR("no transaction found");
    }
    return $trans;
}


sub deleteTransaction {
    my ($self, $id) = @_;
    INFO("attempting to delete transaction <$id>");
    my $result = $self->{transactionMapper}->delete($id);
    if($result == 1) {
        INFO("deleted transaction");
        &Messages::notify("deleteTransaction", "success");
    } else {
        ERROR("could not delete transaction <$id>: $result");
        &Messages::notify("deleteTransaction", "failure", $result);
    }
}


sub updateTransaction {
    my ($self, $hashref) = @_;
    INFO("updating transaction, args are:  " . Dumper($hashref));
    my $trans = Transaction->new($hashref);
    my $result = $self->{transactionMapper}->update($trans);
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
    my ($self, $hashref) = @_;
    INFO("setting end of month balance, args are: " . Dumper($hashref) );
    my $bal = Balance->new($hashref);
    my $result = $self->{balanceMapper}->replace($bal);  
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
    my ($self, @args) = @_;
    INFO("setting end of month balance, args are: " . Dumper(\@args) );
    my $bal = $self->{balanceMapper}->get(@args);
    if($bal) {
        INFO("balance result: " . Dumper($bal));
    } else {
        INFO("no balance found");
    }
    return $bal;
}


####### reports

sub getReport {
    my ($self, $reportName) = @_;
    INFO("getting report $reportName");
    my $rep = $self->{reportMapper}->getReport($reportName);
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
    my ($self) = @_;
    return [$self->{miscData}->getColumn('months')];
}


sub getYears {
    my ($self) = @_;
    return [$self->{miscData}->getColumn('years')];
}


sub getDays {
    my ($self) = @_;
    return [$self->{miscData}->getColumns('days')];
}


sub getAccounts {
    my ($self) = @_;
    return [$self->{miscData}->getColumn('accounts')];
}


sub getTransactionTypes {
    my ($self) = @_;
    return [$self->{miscData}->getColumn('types')];
}


sub getComments {
    my ($self) = @_;
    my @comments = $self->{miscData}->getColumn('comments');
    return [sort {lc $a cmp lc $b} @comments];
}


sub getIDs {
    my ($self) = @_;
    my @ids = $self->{miscData}->getColumn('ids');
    return [sort {$a <=> $b} @ids];
}


sub getAvailableReports {
    my ($self) = @_;
    return $self->{reportMapper}->getAvailableReports();
}

######################################################
# scalars

sub getWebAddress {
    my ($self) = @_;
    return $self->{miscData}->getScalar('webAddress');
}


sub getVersion {
    my ($self) = @_;
    return $self->{miscData}->getScalar('version');
}


sub getCurrentYear {
    my ($self) = @_;
    return $self->{miscData}->getScalar('currentYear');
}


1;