use strict;
use warnings;

package TransactionMapper;
use Transaction;
use Try::Tiny;



sub new {
    my ($class, $dbh) = @_;
    my $self = {dbh => $dbh};
    bless($self, $class);
    return $self;
}


# issues:
#   1. check that trans is an instance of 'Transaction'?  
#   2. check that trans is valid
# contract
#   1:  success
#   anything else:  failure
sub save {
	my ($self, $trans) = @_;
    try {
        my %fields = %$trans;
        my $date = join('-', $fields{year}, $fields{month}, $fields{day});
        my $result = $self->{dbh}->do(
            'insert into transactions 
                (`date`, comment, amount, type, 
                    account, isreceiptconfirmed, isbankconfirmed)
                values(?, ?, ?, ?, ?, ?, ?)', undef,
            $date, $fields{comment}, $fields{amount}, $fields{type}, 
                $fields{account}, $fields{isreceiptconfirmed}, $fields{isbankconfirmed}
        );
        return $result;
    } catch {
        return $_;
    };
}


# contract:
#   returns Transaction instance if found, otherwise false
sub get {
    my ($self, $id) = @_;
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
    my $sth = $self->{dbh}->prepare($statement);
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
    my ($self, $trans) = @_;
    try {
        my %fields = %$trans;
        my $date = join('-', $fields{year}, $fields{month}, $fields{day});
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
                $date, $fields{comment}, $fields{amount}, $fields{account}, 
                    $fields{isreceiptconfirmed}, $fields{isbankconfirmed}, 
                    $fields{type}, $fields{id} );
        return $result;
    } catch {
        return $_;
    };
}


sub delete {
    my ($self, $id) = @_;
    my $result = $self->{dbh}->do('
        delete from transactions where id = ? limit 1', undef, $id);    
    return $result;
}

1;