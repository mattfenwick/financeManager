use strict;
use warnings;

package Messages;
use Log::Log4perl qw(:easy);


my %listeners = (
    'saveTrans'   => [],
    'editTrans'   => [],
    'saveBalance' => [],
    'deleteTrans' => []
);


# issues
#   1. generate and return listener identifier
sub addListener {
    my ($event, $code) = @_;
    if(!defined($listeners{$event})) {
        die "bad event type: <$event>";
    }
    if(ref($code) ne "CODE") {
        die "need code reference (got " . ref($code) . " )";
    }
    my $ls = $listeners{$event}; # be very careful not to create a NEW copy
    push(@$ls, $code);
}


# issues
#   1. not implemented
sub removeListener {
	my ($id) = @_;
	die;
}


sub notify {
    my ($event, @rest) = @_;
    if(!defined($listeners{$event})) {
        die "bad event type: <$event>";
    }
    my @ls = @{$listeners{$event}};
    INFO("notifying " . scalar(@ls) . " listeners of event <$event> with args <@rest>");
    for my $l (@ls) {
        $l->(@rest);
        INFO("<$event> listener succeeded");
    }
}


1;