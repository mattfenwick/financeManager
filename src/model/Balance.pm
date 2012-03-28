use strict;
use warnings;

package Balance;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use Messages;


#####################################################

my $dbh;

sub setDbh {
    my ($newDbh) = @_;
    if($dbh) {
        die "dbh already set: <$dbh>";
    }
    $dbh = $newDbh;
}

######################################################


sub new {
    my ($class, $self) = @_;
    bless($self, $class);
    $self->_validate();
    return $self;
}


sub _validate {
    my ($self) = @_;
    my $year = $self->{year};
    die "bad year <$year>" unless $year =~ /^\d{4}$/;
    # TODO just assume account is okay, or actually check it?
    die "bad account" unless $self->{account};
    my $month = $self->{month};
    die "bad month <$month>" unless $month =~ /^\d{1,2}$/;
    die "bad month <$month>" unless ($month < 13 && $month > 0);
        # a $ amount is an optional '-' sign followed by at least 1 digit,
        #        followed by an optional decimal and up to 0-2 digits 
    my $amount = $self->{amount};
    die "bad amount <$amount>" unless $amount =~ /^-?\d+(?:\.\d{0,2})?$/;
}


#######################################################
# static methods

sub replace { # follows the MySQL meaning of replace: 
            # add if no match for primary key, otherwise update
    my ($bal) = @_;
    my %fields = %$bal;
    INFO("setting end of month balance: " . Dumper(\%fields) );
    my $result = $dbh->do('replace into endofmonthbalances
                (monthid, yearid, amount, account)
                values(?, ?, ?, ?)', undef,
                $fields{month}, $fields{year}, $fields{amount}, $fields{account});
    # TODO what does $dbh->do return?  
    #   3 modes: 
    #     failure, 
    #     new row, 
    #     overwrite existing row with new values.   
    #   return codes ???
    if($result == 1) {
        INFO("save balance succeeded, result:  <$result>");
        &Messages::notify("saveBalance", "success");
    } else {
        INFO("save balance failed, result: <$result>");
        &Messages::notify("saveBalance", "failure");
    }
}


sub get { # returns Balance, or false if no match found
    my ($month, $year, $account) = @_;
    INFO("fetching end of month balance: " . Dumper(\@_) );
    my $statement = '
        select * from endofmonthbalances
            where monthid = ? and yearid = ? and account = ?';
    my $sth = $dbh->prepare($statement);
    $sth->execute($month, $year, $account);
    my $result = $sth->fetchrow_hashref();
    if ($result) {
        INFO("end of month balance found: $result->{amount}");
        return Balance->new($result);    
    } else {
        INFO("no end of month balance found");
        return undef;
    }
}

1;