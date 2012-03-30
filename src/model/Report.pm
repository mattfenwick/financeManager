use strict;
use warnings;

package Report;
use Log::Log4perl qw(:easy);


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

1;