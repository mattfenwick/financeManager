use strict;
use warnings;

package Transaction;



sub new {
    my ($class, $fields) = @_;
    my $self = {};
    for my $f (keys %$fields) {
        $self->{$f} = $fields->{$f};
    }
	bless($self, $class);
	$self->_validate();
	return $self;
}


my %validations = (
    date => sub {
        return $_[0] =~ /^\d{4}-\d{1,2}-\d{1,2}$/;
    },
    
    purchasedate => sub {
        return $_[0] =~ /^\d{4}-\d{1,2}-\d{1,2}$/;
    },
    
    savedate => sub {
        return $_[0] =~ /^\d{4}-\d{1,2}-\d{1,2}$/;
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
        return ($_[0] =~ /^\d+$/ || !defined($_[0]));
    }
);


sub _validate {
    my ($self) = @_;
    my $n = scalar(keys %validations);
    my $m = scalar(keys %$self);
    # there can be one less field in self because:
    #    the id may not be set
    if($n != $m && ($n - 1) != $m) {
        die "missing fields (expected $n, got $m)";
    }
    for my $key (keys %$self) {
        my $checker = $validations{$key};
        if(!$checker) {
            die "bad field name: <$key>";
        }
        my $val = $self->{$key};
        if(!$checker->($val)) {
            die "bad $key: <$val>";
        }
    }
}

1;