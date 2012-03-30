use strict;
use warnings;

package BalanceMapper;
use Balance;
use Try::Tiny;



sub new {
    my ($class, $dbh) = @_;
    my $self = {dbh => $dbh};
    bless($self, $class);
    return $self;
}


# contract
#   follows the MySQL meaning of replace: 
#   add if no match for primary key, otherwise update
sub replace {
    my ($self, $bal) = @_;
    try {
        my %fields = %$bal;
        my $result = $self->{dbh}->do('
            replace into endofmonthbalances
                (monthid, yearid, amount, account)
                values(?, ?, ?, ?)', undef,
            $fields{month}, $fields{year}, $fields{amount}, $fields{account}
        );
        return $result;
    } catch {
        return $_;
    };
}


# contract
#    returns Balance, or false if no match found
sub get {
    my ($self, $month, $year, $account) = @_;
    INFO("fetching end of month balance: " . Dumper(\@_) );
    my $statement = '
        select amount, monthid as month, yearid as year, account
        from endofmonthbalances
        where monthid = ? and yearid = ? and account = ?';
    my $sth = $self->{dbh}->prepare($statement);
    $sth->execute($month, $year, $account);
    my $result = $sth->fetchrow_hashref();
    if($result) {
        return Balance->new($result);
    } else {
        return $result;
    }
}


1;