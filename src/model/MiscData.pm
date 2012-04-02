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


sub new {
    my ($class, $dbh) = @_;
    my $self = {
        dbh => $dbh
    };
    bless($self, $class);
    return $self;
}


sub getColumnNames {
    return (keys %tableFinder);
}


sub getScalarNames {
    return (keys %scalars);
}


sub getScalar {
	my ($self, $key) = @_;
	if(!defined($scalars{$key})) {
	    my $message = "unrecognized key: <$key>";
	    ERROR($message);
		die $message;
	} else {
		return $scalars{$key};
	}
}


sub getColumn {
    my ($self, $name) = @_;
    INFO("fetching column <$name>");
    
    # TODO get rid of special case
    if($name eq "days") {
    	return [@days];
    }
    
    my $entry = $tableFinder{$name};
    if(!$entry) {
        my $message = "no table found for column $name";
        ERROR($message);     
        die $message;
    } 
    
    my ($column, $table) = @$entry;
    my $sth = $self->{dbh}->prepare("select $column from $table");
    $sth->execute();
    my $result = $sth->fetchall_arrayref();
    my @values = ();
    for my $row (@$result) {
        push(@values, $row->[0]);
    }
    INFO("column <$name> fetched");
    return [@values];
}

1;