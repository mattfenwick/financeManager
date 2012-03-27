use strict;
use warnings;

package Report;
use Log::Log4perl qw(:easy);


my %queries = (
    'transactions'                  => 'select * from p_transactions',
    'comment counts'                => 'select * from p_commentcounts',
    'transaction type counts'       => 'select * from p_transactiontypecounts',
    'end of month balances'         => 'select * from p_endofmonthbalances',
    'declared vs calculated totals' => 'select * from p_comparison',
    'totals per month'              => 'select * from p_monthlytotals',
    'unconfirmed by bank'           => 'select * from p_transactions where not `bank-confirmed`',
    'unconfirmed by receipt'        => 'select * from p_transactions where not `have receipt`',
    'possible duplicates'           => 'select * from p_potentialduplicates',
    'transactions per month'        => 'select * from p_transactionspermonth',
    'recent transactions'           => 'select * from p_recenttransactions',
    'running totals'                => 'select * from p_runningtotals'
);

#####################################################

my $dbh;

sub setDbh {
    my ($newDbh) = @_;
    if($dbh) {
        die "dbh already set: <$dbh>";
    }
    $dbh = $newDbh;
}

#####################################################

sub new {
	my ($class, $headings, $rows) = @_;
	my ($self) = {
		headings => $headings,
		rows => $rows
	};
	bless($self, $class);
	return $self;
}


sub getRows {
	my ($self) = @_;
	return $self->{rows};
}


sub getHeadings {
	my ($self) = @_;
	return $self->{headings};
}


############################################################
# static-ish methods

sub getAvailableReports {
    return [keys %queries];
}


sub getReport { # originally had planned for something like (query => 'viewComments', month => '11') ... but it's not used
    my ($options) = @_;
    INFO("report requesting with options: " . Dumper($options) );
    my %options = %$options;
    my $statement = $queries{$options{query}} || die "no query found";
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    my @headings = @{$sth->{NAME_lc}};
    my $rows = $sth->fetchall_arrayref();
    INFO("report fetched from database");
    return Report->new([@headings], $rows);
}

1;