use strict;
use warnings;

package MiscData;
use Log::Log4perl qw(:easy);


my @days = (0 .. 31); # include 0 as an "unknown" value

my $webAddress = "https://github.com/mattfenwick/financeManager";
my $version = "1.1.0";

###################################################

my $dbh;

sub setDbh {
    my ($newDbh) = @_;
    if($dbh) {
        die "dbh already set: <$dbh>";
    }
    $dbh = $newDbh;
}

###################################################

sub getWebAddress {
    return $webAddress;
}


sub getVersion {
    return $version;
}


sub getMonths {
    return [&getColumn('months')];
}


sub getYears {
    return [&getColumn('years')];
}


sub getDays {
    return [@days];
}


sub getAccounts {
    return [&getColumn('accounts')];
}


sub getTransactionTypes {
    return [&getColumn('types')];
}


sub getComments {
    my @comments = &getColumn('comments');
    return [sort {lc $a cmp lc $b} @comments];
}


sub getIDs {
    my @ids = &getColumn('ids');
    return [sort {$a <=> $b} @ids];
}


sub getColumn {
    my ($name) = @_;
    INFO("fetching column <$name>");
    my %tableFinder = (
        'ids'         =>     ['id',          'transactions'],
        'comments'    =>     ['comment',     'p_commentcounts'],
        'types'       =>     ['description', 'transactiontypes'],
        'accounts'    =>     ['name',        'myaccounts'],
        'years'       =>     ['id',          'years'],
        'months'      =>     ['id',          'months']
    );
    my $entry = $tableFinder{$name} || die "no table found for column $name";
    my ($column, $table) = @$entry;
    my $sth = $dbh->prepare("select $column from $table");
    $sth->execute();
    my $result = $sth->fetchall_arrayref();
    my @values = ();
    for my $row (@$result) {
        push(@values, $row->[0]);
    }
    INFO("column <$name> fetched");
    return @values;
}

1;