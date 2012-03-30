use strict;
use warnings;

package Transaction;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use Try::Tiny;
use MiscData;


###############################################################

my $dbh;

sub setDbh {
	my ($newDbh) = @_;
	if($dbh) {
		die "dbh already set: <$dbh>";
	}
	$dbh = $newDbh;
}

###############################################################


sub new {
	my ($class, $self) = @_;
	bless($self, $class);
	$self->_validate();
	return $self;
}


sub _validate {
    my ($self) = @_;
    my $year = $self->{year};
    die "bad year: <$year>" unless $year =~ /^\d{4}$/;
    my $month = $self->{month};
    die "bad month: <$month>" unless 
        ($month =~ /^\d{1,2}$/ && $month <= 12 && $month > 0);
    my $day = $self->{day};
    die "bad day: <$day>" unless 
        ($month =~ /^\d{1,2}$/ && $day <= 31 && $day >= 0);

    # TODO does this work if the user enters nothing?
    die "missing comment" unless defined($self->{comment});
    my $amount = $self->{amount};
      # a $ amount is at least 1 digit,
      #    followed by an optional decimal and up to 0-2 digits
      #    it is ALWAYS positive (because the type specifies deposit/withdrawal)
    die "bad amount: $amount" unless $amount =~ /^\d+(?:\.\d{0,2})?$/;
    
    die "bad type: $self->{type}"               unless  
        &_inArray($self->{type}, &MiscData::getColumn('types'));
    my $account = $self->{account};
    die "bad account: <$account>"    unless  
        &_inArray($account, &MiscData::getColumn('accounts'));
    die "missing isReceiptConfirmed" unless  defined($self->{isReceiptConfirmed});
    die "missing isBankConfirmed"    unless  defined($self->{isBankConfirmed});
}

sub _inArray {
    my ($elem, @arr) = @_;
    for my $e (@arr) {
        if($e eq $elem) {
            return 1;
        }
    }
    return 0;
}

###############################################################
# data access layer methods

# issues:
#   1. check that trans is an instance of 'Transaction'?  
#   2. check that trans is valid
#   3. where does $dbh come from?
# contract
#   1:  success
#   anything else:  failure
sub save {
	my ($trans) = @_;
    try {
        my %fields = %$trans;
        my $date = join('-', $fields{year}, $fields{month}, $fields{day});
        my $result = $dbh->do(
            'insert into transactions 
                (`date`, comment, amount, type, 
                    account, isreceiptconfirmed, isbankconfirmed)
                values(?, ?, ?, ?, ?, ?, ?)', undef,
            $date, $fields{comment}, $fields{amount}, $fields{type}, 
                $fields{account}, $fields{receipt}, $fields{bank}
        );
        return $result;
    } catch {
        return $_;
    };
}


# contract:
#   returns Transaction instance if found, otherwise false
sub get {
    my ($id) = @_;
    my $statement = '
        select 
            id,
            comment,
            amount,
            type,
            account,
            isreceiptconfirmed,
            isbankconfirmed, 
            year(`date`) as year, 
            month(`date`) as month, 
            day(`date`) as day 
        from transactions where id = ?';
    my $sth = $dbh->prepare($statement);
    $sth->execute($id);
    my $result = $sth->fetchrow_hashref();
    if($result) {
        return Transaction->new($result);
    } else {
        return $result;
    }
}


# contract:
#   1:  success
#   anything else:  failure
sub update {
    my ($trans) = @_;
    try {
        my %fields = %$trans;
        my $result = $dbh->do('
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
        return $result;
    } catch {
        return $_;
    };
}


sub delete {
    my ($id) = @_;
    my $result = $dbh->do('
        delete from transactions where id = ? limit 1', undef, $id);    
    return $result;
}

1;