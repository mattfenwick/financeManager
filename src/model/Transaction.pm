use strict;
use warnings;

package Transaction;
use Date;
use Log::Log4perl qw(:easy);



sub new {
    my ($class, $fields) = @_;
    my $r = ref($fields);
    if($r ne "HASH") {
        my $message = "expected hash ref, got <$r>";
        ERROR($message);
        die $message;
    }
    my $self = {};
    for my $f (keys %$fields) {
        $self->{$f} = $fields->{$f};
    }
    my @dates = qw/savedate purchasedate date/;
    # initialize all date strings to Dates (if they're defined)
    for my $d (@dates) {
        INFO("creating date $d");
        if($self->{$d}) {
            $self->{$d} = Date->fromYMD($self->{$d});
        }
    }
	bless($self, $class);
	$self->_validate();
	return $self;
}


my %validations = (
    # rely on Date for checking date values
    date => sub {
        return ref($_[0]) eq "Date";
    },
    
    purchasedate => sub {
        return ref($_[0]) eq "Date";
    },
    
    # this is a read-only field provided by the database
    #   it won't be set when Transaction built off of data from GUI
    savedate => sub {
        return (!defined($_[0]) || ref($_[0]) eq "Date");
    },
    
    comment => sub {
        return defined($_[0]);
    },
    
      # a $ amount is at least 1 digit,
      #    followed by an optional decimal and up to 0-2 digits
      #    it is ALWAYS positive (because the type specifies deposit/withdrawal)
    amount => sub {
        return $_[0] =~ /^\d+(?:\.\d{0,2})?$/;
    },
    
    type => sub {
        return (length($_[0]) > 0);
    },
    
    account => sub {
        return (length($_[0]) > 0);        
    },
    
    isreceiptconfirmed => sub {
        return ($_[0] == 1 || $_[0] == 0);
    },
    
    isbankconfirmed => sub {
        return ($_[0] == 1 || $_[0] == 0);
    },
    
    id => sub {
        return (!defined($_[0]) || $_[0] =~ /^\d+$/);
    }
);


sub _validate {
    my ($self) = @_;
    my $n = scalar(keys %validations);
    my $m = scalar(keys %$self);
    # extra keys not in %validations?  bad!
    for my $key (keys %$self) {
        if(!defined($validations{$key})) {
            die "unrecognized key: <$key>";
        }
    }
    # validate all keys in %validations
    for my $key (keys %validations) {
        my $checker = $validations{$key};
        my $val = $self->{$key};
        if(!$checker->($val)) {
            die "bad $key: <$val>";
        }
    }
}

1;