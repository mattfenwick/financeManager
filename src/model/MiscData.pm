use strict;
use warnings;

package MiscData;
use Log::Log4perl qw(:easy);


my @days = (0 .. 31); # include 0 as an "unknown" value

my $webAddress = "https://github.com/mattfenwick/financeManager";
my $version = "1.1.0";



sub new {
	my ($class, $dbh) = @_;
	my $self = {
		dbh => $dbh
	};
	bless($self, $class);
	return $self;
}


sub getWebAddress {
    my ($self) = @_;
    return $webAddress;
}


sub getVersion {
    my ($self) = @_;
    return $version;
}


sub getMonths {
    my ($self) = @_;
    return [$self->getColumn('months')];
}


sub getYears {
    my ($self) = @_;
    return [$self->getColumn('years')];
}


sub getDays {
    return [@days];
}


sub getAccounts {
    my ($self) = @_;
    return [$self->getColumn('accounts')];
}


sub getTransactionTypes {
    my ($self) = @_;
    return [$self->getColumn('types')];
}


sub getComments {
    my ($self) = @_;
    my @comments = $self->getColumn('comments');
    return [sort {lc $a cmp lc $b} @comments];
}


sub getIDs {
    my ($self) = @_;
    my @ids = $self->getColumn('ids');
    return [sort {$a <=> $b} @ids];
}


sub getColumn {
    my ($self, $name) = @_;
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
    my $sth = $self->{dbh}->prepare("select $column from $table");
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