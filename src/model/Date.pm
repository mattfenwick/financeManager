use strict;
use warnings;


package Date;
use Log::Log4perl qw(:easy);


sub new {
    my ($class, $year, $month, $day) = @_;
    DEBUG("creating date, args: <@_>");
    my $self = {
        year   =>  $year,
        month  =>  $month,
        day    =>  $day
    };
    bless($self, $class);
    $self->_validate();
    return $self;
}


sub fromYMD {
    my ($class, $dateString) = @_;
    DEBUG("parsing date, args: <@_>");
    if(!($dateString =~ /^(\d{4})-(\d{1,2})-(\d{1,2})$/)) {
        die "bad date: <$dateString>";
    }
    return Date->new($1, $2, $3);
}


sub toYMD {
    my ($self) = @_;
    return join('-', $self->{year}, $self->{month}, $self->{day});
}


my %validations = (
    # a year is a four digit number
    year    => sub {
        return $_[0] =~ /^\d{4}$/;
    },
    
    # a month is between 0 and 12, inclusive
    #   0 means "unknown"
    month   => sub {
        return (defined($_[0]) && $_[0] < 13 && $_[0] >= 0);
    },
    
    # a day is between 0 and 31, inclusive
    #   0 means "unknown"
    day     => sub {
        return (defined($_[0]) && $_[0] < 32 && $_[0] >= 0);
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
            ERROR("bad field name: <$key>");
            die "bad field name: <$key>";
        }
        my $val = $self->{$key};
        if(!$checker->($val)) {
            ERROR("bad $key: <$val>");
            die "bad $key: <$val>";
        }
    }
}

1;