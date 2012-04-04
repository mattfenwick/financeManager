use strict;
use warnings;


package Date;


sub new {
    my ($class, $year, $month, $day) = @_;
    my $self = {
        year   =>  $year,
        month  =>  $month,
        day    =>  $day
    };
    bless($self, $class);
    return $self;
}


my %validations = (
    # a year is a four digit number
    year    => sub {
        return $_[0] =~ /^\d{4}$/;
    },
    
    # a month is between 1 and 12, inclusive
    month   => sub {
        return ($_[0] < 13 && $_[0] > 0);
    },
    
    # a day is between 0 and 31, inclusive
    #   0 means "unknown"
    day     => sub {
        return ($_[0] < 32 && $_[0] >= 0);
    }
);


sub _validate {
    my ($self) = @_;
    my $n = scalar(keys %validations);
    my $m = scalar(keys %$self);
    if($n != $m) {
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