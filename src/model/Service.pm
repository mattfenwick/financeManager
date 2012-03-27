use strict;
use warnings;

package Service;
use Transaction;
use Balance;
use MiscData;
use Report;


####################################################
# domain objects

sub saveTransaction {
	my $trans = Transaction->new(@_);
	&Transaction::save($trans);
}


sub getTransaction {
	my ($id) = @_;
	my $trans = &Transaction::get($id);
	return $trans;
}


sub deleteTransaction {
	my ($id) = @_;
	&Transaction::delete($id);
}


sub updateTransaction {
	my $trans = Transaction->new(@_);
	&Transaction::update($trans);
}


sub saveBalance {
    my $bal = Balance->new(@_);
    &Balance::replace($bal);
}


sub updateBalance {
    my $bal = Balance->new(@_);
    &Balance::replace($bal);
}


sub getBalance {
	&Balance::get(@_);
}


sub getReport {
	return &Report::getReport(@_);
}


###########################################################
# "columns"

sub getMonths {
    return [&MiscData::getColumn('months')];
}


sub getYears {
    return [&MiscData::getColumn('years')];
}


sub getDays {
    return [&MiscData::getColumns('days')];
}


sub getAccounts {
    return [&MiscData::getColumn('accounts')];
}


sub getTransactionTypes {
    return [&MiscData::getColumn('types')];
}


sub getComments {
    my @comments = &MiscData::getColumn('comments');
    return [sort {lc $a cmp lc $b} @comments];
}


sub getIDs {
    my @ids = &MiscData::getColumn('ids');
    return [sort {$a <=> $b} @ids];
}


sub getAvailableReports {
	return &Report::getAvailableReports();
}

######################################################
# scalars

sub getWebAddress {
    return &MiscData::getScalar('webAddress');
}


sub getVersion {
    return &MiscData::getScalar('version');
}


sub getCurrentYear {
    return &MiscData::getScalar('currentYear');
}


1;