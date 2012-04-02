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
    year => sub {
        return $_[0] =~ /^\d{4}$/;
    },
    
    month => sub {
        return ($_[0] =~ /^\d{1,2}$/ && $_[0] <= 12 && $_[0] > 0);
    },
    
    day => sub {
        return ($_[0] =~ /^\d{1,2}$/ && $_[0] <= 31 && $_[0] >= 0);
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