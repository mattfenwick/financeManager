use strict;
use warnings;

package Service;
use Balance;
use Report;
use Transaction;
use MiscData;


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


sub getColumn {
	my ($columnName) = @_;
	if($columnName eq "availableReports") {
		return &Report::getAvailableReports();
	} else {
		return &MiscData::getColumn($columnName);
	}
}


sub getReport {
	return &Report::getReport(@_);
}


1;