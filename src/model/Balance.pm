use strict;
use warnings;

package Balance;



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
    bless($self, $class);
    $self->_validate();
    return $self;
}


my %validations = (
    year    => sub {
        return $_[0] =~ /^\d{4}$/;
    },
    
    account => sub {
        return (length($_[0]) > 0);
    },
    
    month   => sub {
        return ($_[0] < 13 && $_[0] > 0);
    },
    
        # a $ amount is an optional '-' sign followed by at least 1 digit,
        #        followed by an optional decimal and up to 0-2 digits 
    amount  => sub {
        return $_[0] =~ /^-?\d+(?:\.\d{0,2})?$/;
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