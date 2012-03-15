use strict;
use warnings;

package MockSTH;



sub new {
    my ($class, $query, $returnValue, $heading) = @_;
    my ($self) = {
    	query        => $query,
    	returnValue  => $returnValue,
    	NAME_lc      => $heading,
    };
    bless($self, $class);
    return $self;
}


sub execute {
	1; # ???
}


sub fetchrow_hashref {
	my ($self) = @_;
	return $self->{returnValue};
}


sub fetchall_arrayref {
	my ($self) = @_;
	return $self->{returnValue};
}


1;