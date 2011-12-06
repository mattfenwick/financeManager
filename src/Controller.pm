use strict;
use warnings;


package Controller;
use Data::Dumper;
use DBI;
use Log::Log4perl qw(:easy);


my $database    = "finance";
my $user        = "financeclient";
my $password    = "financeclient";

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
my @days = (0 .. 31);


sub new {
    my ($class) = @_;
    my ($self) = {};
    bless($self, $class);
    INFO("attempting to connect to database");
    $self->{dbh} = DBI->connect("DBI:mysql:" . $database, 
        $user, $password, {RaiseError => 1});
    INFO("database connection succeeded -- $database $user");
    return $self;
}

sub cleanUp {
    my ($self) = @_;
    INFO("cleaning up database connection");
    $self->{dbh}->disconnect();
}


sub addTransaction { # \%
    my ($self, $fields) = @_;
    my %fields = %$fields;
    INFO("adding transaction:  values are " . Dumper(\%fields) );
    my $result = $self->{dbh}->do('insert into transactions 
                (`date`, comment, amount, type, account, isReceiptConfirmed, isBankConfirmed)
                values(?, ?, ?, ?, ?, ?, ?)', undef,
            $fields{date}, $fields{comment}, $fields{amount}, $fields{type}, 
                $fields{account}, $fields{receipt}, $fields{bank});
    INFO("add transaction succeeded, result is:  $result");
    return $result;
}


sub replaceMonthBalance { # follows the MySQL meaning of replace: 
            # add if no match for primary key, otherwise update
    my ($self, $fields) = @_;
    my %fields = %$fields;
    INFO("setting end of month balance: " . Dumper(\%fields) );
    my $result = $self->{dbh}->do('replace into endofmonthbalances
                (monthid, yearid, amount, account)
                values(?, ?, ?, ?)', undef,
                $fields{month}, $fields{year}, $fields{amount}, $fields{account});
    INFO("end of month balance successfully set, result is:  $result");
    return $result;
}


sub getMonthBalance { # returns hashref, or false if no match found
    my ($self, $fields) = @_;
    my %fields = %$fields;
    INFO("fetching end of month balance: " . Dumper(\%fields) );
    my $statement = '
        select * from endofmonthbalances
            where monthid = ? and yearid = ? and account = ?';
    my $sth = $self->{dbh}->prepare($statement);
    $sth->execute($fields{month}, $fields{year}, $fields{account});
    my $result = $sth->fetchrow_hashref();
    if ($result) {
        INFO("end of month balance found: $result->{amount}");
        return $result->{amount};    
    } else {
        INFO("no end of month balance found");
        return undef;
    }
}


sub getTransaction { # returns hashref, or die's if no transaction found
    my ($self, $id) = @_;
    INFO("attempting to fetch transaction of id <$id>");
    my $statement = '
        select 
            *, 
            year(`date`) as year, 
            month(`date`) as month, 
            day(`date`) as day 
        from transactions where id = ?';
    my $sth = $self->{dbh}->prepare($statement);
    $sth->execute($id);
    my $result = $sth->fetchrow_hashref();
    if ($result) {
        INFO("found transaction: " . Dumper($result) );
        return $result;
    } else {    
        INFO("no transaction found (id <$id>)");
        die "no transaction with id $id found";
    }
}


sub getReport { # \% something like (query => 'viewComments', month => '11')
    my ($self, $options) = @_;
    INFO("report requesting with options: " . Dumper($options) );
    my %options = %$options;
    my $statement = $queries{$options{query}} || die "no query found";
    my $sth = $self->{dbh}->prepare($statement);
    $sth->execute();
    my @headings = @{$sth->{NAME_lc}};
    my $rows = $sth->fetchall_arrayref();
    INFO("report fetched from database");
    return ([@headings], $rows);
}


sub updateTransaction { # \%
    my ($self, $fields) = @_;
    INFO("updating transaction:  " . Dumper($fields));
    my %fields = %$fields;
    print "update transaction: " . Dumper(\%fields);
    my $result = $self->{dbh}->do('
        update transactions set
            `date` = ?, 
            comment = ?, 
            amount = ?, 
            account = ?, 
            isreceiptconfirmed = ?, 
            isbankconfirmed = ?,
            type = ?
        where id = ?', undef,
            $fields{date}, $fields{comment}, $fields{amount}, $fields{account}, 
                $fields{receipt}, $fields{bank}, $fields{type}, $fields{id} );
    if($result == 1) {
        INFO("update transaction succeeded, result:  <$result>");
        return $result;
    } else {
        INFO("update transaction failed, result: <$result>");
        die "update transaction failed";
    }
}


sub deleteTransaction {
    my ($self, $id) = @_;
    INFO("delete transaction of id:  <$id>");
    my $result = $self->{dbh}->do('
        delete from transactions where id = ? limit 1', undef, $id);    
    if($result == 1) {
        INFO("delete transaction <$id> succeeded");
        return $result;
    } else {    
        INFO("delete transaction <$id> failed");
        die "delete transaction <$id> failed";
    }
}


sub getAvailableReports {
    return [keys %queries];
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