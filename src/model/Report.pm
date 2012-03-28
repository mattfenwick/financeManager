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
	# throw an exception if it's ill-formed
	$self->_validate();
	return $self;
}


sub _validate {
	# check for:
	#   1. each row has same length as number of columns -- no extras!
	my ($self) = @_;
	my @headings = @{$self->{headings}};
	my @rows = @{$self->{rows}};
	my $numCols = scalar(@headings);
	my $i = 0;
	for my $row (@rows) {
		my $rowLen = scalar(@$row);
		if($rowLen != $numCols) {
			ERROR("found report row with invalid length (<$numCols>, <$rowLen>");
			die "row <$i> has invalid number of columns.  wanted <$numCols>, got <$rowLen>";
		}
		$i++;
	}
	INFO("validated report with <$i> rows");
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


sub getReport {
    my ($reportName) = @_;
    INFO("report <$reportName> requested");
    my $statement = $queries{$reportName} || die "no query found";
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    my @headings = @{$sth->{NAME_lc}};
    my $rows = $sth->fetchall_arrayref();
    INFO("report fetched from database");
    return Report->new([@headings], $rows);
}

1;