use strict;
use warnings;

package MockDB;
use MockSTH;


sub new {
    my ($class, $queryResults) = @_;
    die "need hash ref" unless (ref($queryResults) eq "HASH");
    my ($self) = {
    	doQueries    => [],
    	connected    => 1, # start out connected
    	queryResults => $queryResults
    };
    bless($self, $class);
    return $self;
}


sub do {
	my ($self, $query, $something, @bindParams) = @_;
	die unless $self->{connected};
	
	my $returnValue = $self->{queryResults}->{$query};
	if(!defined($returnValue)) {die "no return value for query <$query>"};
	
	return $returnValue;
}


sub prepare {
	my ($self, $query) = @_;
	die unless $self->{connected};

	my $heading = $self->{queryResults}->{heading};
	if(!exists($self->{queryResults}->{$query})) {die "no return value for query <$query>"};
	if(!defined($heading)) {die "no heading"};

	return MockSTH->new($query, $self->{queryResults}->{$query}, $heading);
}


sub disconnect {
	my ($self) = @_;
	$self->{connected} = 0;
}


1;