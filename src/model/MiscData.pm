use strict;
use warnings;

package MiscData;
use Log::Log4perl qw(:easy);


my @days = (0 .. 31); # include 0 as an "unknown" value

my %scalars = (
    webAddress   =>   "https://github.com/mattfenwick/financeManager",
    version      =>   "1.2.0",
    currentYear  =>   2012
);

my %tableFinder = (
    'ids'         =>     ['id',          'transactions'     ],
    'comments'    =>     ['comment',     'p_commentcounts'  ],
    'types'       =>     ['description', 'transactiontypes' ],
    'accounts'    =>     ['name',        'myaccounts'       ],
    'years'       =>     ['id',          'years'            ],
    'months'      =>     ['id',          'months'           ]
);

###################################################

my $dbh;

sub setDbh {
    my ($newDbh) = @_;
    if($dbh) {
        die "dbh already set: <$dbh>";
    }
    $dbh = $newDbh;
}


###################################################

sub getColumnNames {
    return (keys %tableFinder);
}


sub getScalarNames {
    return (keys %scalars);
}

###################################################

sub getScalar {
	my ($key) = @_;
	if(!defined($scalars{$key})) {
		die "unrecognized key: <$key>";
	} else {
		return $scalars{$key};
	}
}


sub getColumn {
    my ($name) = @_;
    INFO("fetching column <$name>");
    if($name eq "days") {
    	return [@days]; # TODO get rid of special case
    }
    my $entry = $tableFinder{$name} || die "no table found for column $name";
    my ($column, $table) = @$entry;
    my $sth = $dbh->prepare("select $column from $table");
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