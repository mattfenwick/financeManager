use strict;
use warnings;

package Balance;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use Messages;


my $dbh;


sub setDbh {
	my ($newDbh) = @_;
	if($dbh) {
		die "dbh already set: <$dbh>";
	}
	$dbh = $newDbh;
}


sub new {
    my ($class, $fields) = @_;
    my ($self) = {
    	fields => $fields
    };
    bless($self, $class);
#    $self->validate();
    return $self;
}


#######################################################
# static methods

sub replace { # follows the MySQL meaning of replace: 
            # add if no match for primary key, otherwise update
    my ($bal) = @_;
    my %fields = %{$bal->{fields}};
    INFO("setting end of month balance: " . Dumper(\%fields) );
    my $result = $dbh->do('replace into endofmonthbalances
                (monthid, yearid, amount, account)
                values(?, ?, ?, ?)', undef,
                $fields{month}, $fields{year}, $fields{amount}, $fields{account});
    # TODO what does this return?  3 modes: failure, new row, overwrite existing row with new values.   return codes ???
    if($result == 1) {
        INFO("save balance succeeded, result:  <$result>");
        &Messages::notify("saveBalance", "success");
    } else {
        INFO("save balance failed, result: <$result>");
        $Messages::notify("saveBalance", "failure");
    }
}


sub get { # returns hashref, or false if no match found
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
        return $result->{amount};    
    } else {
        INFO("no end of month balance found");
        return undef;
    }
}

1;