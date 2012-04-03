use strict;
use warnings;

package MockService;
use Log::Log4perl qw(:easy);
use Data::Dumper;

use lib '../src/model';
use Messages;
use Transaction;
use Balance;
use Report;



sub new {
    my ($class) = @_;
    my $self = {
        messages          =>  Messages->new(),
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
    Transaction->new($hashref);
    $self->{messages}->notify("saveTransaction", "success");
}


sub getTransaction {
    my ($self, $id) = @_;
    INFO("attempting to fetch transaction of id <$id>");
    return Transaction->new({
        year => 2012,
        month => 2,
        day   => 24,
        account => "Credit card",
        amount  => 100.20,
        comment => "my first comment",
        type => 'General withdrawal',
        isbankconfirmed => 0,
        isreceiptconfirmed => 1        
    });
}


sub deleteTransaction {
    my ($self, $id) = @_;
    INFO("attempting to delete transaction <$id>");
    $self->{messages}->notify("deleteTransaction", "success");
}


sub updateTransaction {
    my ($self, $hashref) = @_;
    INFO("updating transaction, args are:  " . Dumper($hashref));
    my $trans = Transaction->new($hashref);
    $self->{messages}->notify("updateTransaction", "success");
}


####### balances

sub replaceBalance {
    my ($self, $hashref) = @_;
    INFO("setting end of month balance, args are: " . Dumper($hashref) );
    Balance->new($hashref);
    $self->{messages}->notify("saveBalance", "success");
}


sub getBalance {
    my ($self, @args) = @_;
    INFO("getting end of month balance, args are: " . Dumper(\@args) );
    return Balance->new({
        year => 2012,
        month => 2,
        account => "Credit card",
        amount  => 100.20
    });
}


####### reports

sub getReport {
    my ($self, $reportName) = @_;
    INFO("getting report $reportName");
    return Report->new(["ab", "cd", "ef"], [[1,2,3], [4,5,6], [7,8,9], [1,3,5], [2,4,6], [1,4,7], [1,5,9]]);
}


###########################################################
# "columns"

sub getMonths {
    my ($self) = @_;
    return [1,2,3,4];
}


sub getYears {
    my ($self) = @_;
    return [2005, 2010];
}


sub getDays {
    my ($self) = @_;
    return [1,2,3,4];
}


sub getAccounts {
    my ($self) = @_;
    return ["Account1", "Account2"];
}


sub getTransactionTypes {
    my ($self) = @_;
    return ["withdrawal", "deposit"];
}


sub getComments {
    my ($self) = @_;
    return ["abc", "def"];
}


sub getIDs {
    my ($self) = @_;
    return [13, 14];
}


sub getAvailableReports {
    my ($self) = @_;
    return ["first report", "second report"];
}

######################################################
# scalars

sub getWebAddress {
    my ($self) = @_;
    return "myaddress";
}


sub getVersion {
    my ($self) = @_;
    return "myversion";
}


sub getCurrentYear {
    my ($self) = @_;
    return 1381;
}

#######################################################
# listeners and events

sub addListener {
    my ($self, @args) = @_;
    return $self->{messages}->addListener(@args);
}


sub removeListener {
    my ($self, @args) = @_;
    return $self->{messages}->removeListener(@args);
}


sub notify {
    my ($self, @args) = @_;
    return $self->{messages}->notify(@args);
}


1;