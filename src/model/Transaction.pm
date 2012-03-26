use strict;
use warnings;

package Transaction;
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
	&validate($fields);
	my $self = {
		fields => $fields
	};
	bless($self, $class);
	return $self;
}

###############################################################
# static methods

# issues:
#   1. check that trans is an instance of 'Transaction'?  
#   2. check that trans is valid
#   3. where does $dbh come from?
#   4. where are the messages passed to?
sub save {
	my ($trans) = @_;
    my %fields = %{$trans->{fields}};
    INFO("saving transaction:  values are " . Dumper(\%fields) );
    my $result = $dbh->do('insert into transactions 
                (`date`, comment, amount, type, account, isReceiptConfirmed, isBankConfirmed)
                values(?, ?, ?, ?, ?, ?, ?)', undef,
            $fields{date}, $fields{comment}, $fields{amount}, $fields{type}, 
                $fields{account}, $fields{receipt}, $fields{bank});
    if($result == 1) {
        INFO("save transaction succeeded, result:  <$result>");
        &Messages::notify("saveTrans", "success");
    } else {
        INFO("save transaction failed, result: <$result>");
        &Messages::notify("saveTrans", "failure");
    }
}


# issues:
#   1. should return Transaction instance, not hashref
sub get { # returns hashref, or die's if no transaction found -- should it return false instead?
    my ($id) = @_;
    INFO("attempting to fetch transaction of id <$id>");
    my $statement = '
        select 
            *, 
            year(`date`) as year, 
            month(`date`) as month, 
            day(`date`) as day 
        from transactions where id = ?';
    my $sth = $dbh->prepare($statement);
    $sth->execute($id);
    my $result = $sth->fetchrow_hashref();

    INFO("transaction result: " . Dumper($result) );
    return $result;
}


sub update { # \%
    my ($trans) = @_;
    my %fields = %{$trans->{fields}};
    INFO("updating transaction:  " . Dumper(%fields));
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
    if($result == 1) {
        INFO("update transaction succeeded, result:  <$result>");
        &Messages::notify("editTrans", "success");
    } else {
        INFO("update transaction failed, result: <$result>");
        &Messages::notify("editTrans", "failure");
    }
}


sub delete {
    my ($id) = @_;
    INFO("delete transaction of id:  <$id>");
    my $result = $dbh->do('
        delete from transactions where id = ? limit 1', undef, $id);    
    if($result == 1) {
        INFO("delete transaction <$id> succeeded");
        &Messages::notify("deleteTrans", "success");
    } else {    
        INFO("delete transaction <$id> failed");
        &Messages::notify("deleteTrans", "failure");
    }
}

1;