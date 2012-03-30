use strict;
use warnings;

package ReportMapper;
use Report;


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


sub new {
    my ($class, $dbh) = @_;
    my $self = {
        dbh => $dbh
    };
    bless($self, $class);
    return $self;
}


sub getAvailableReports {
    return [keys %queries];
}


sub getReport {
    my ($self, $reportName) = @_;
    my $statement = $queries{$reportName} || die "no query found";
    my $sth = $self->{dbh}->prepare($statement);
    $sth->execute();
    my @headings = @{$sth->{NAME_lc}};
    my $rows = $sth->fetchall_arrayref();
    return Report->new([@headings], $rows);
}

1;