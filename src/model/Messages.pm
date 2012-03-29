use strict;
use warnings;

package Messages;
use Log::Log4perl qw(:easy);
use Data::Dumper;


my %listenerIds = ();

my %listeners = (
    'saveTransaction'   => {},
    'updateTransaction' => {},
    'deleteTransaction' => {},
    'saveBalance'       => {}
);

my $currentId = 1;


sub addListener {
    my ($event, $code) = @_;
    if(ref($code) ne "CODE") {
        my $message = "need code reference (got <" . ref($code) . ">)";
        ERROR($message);
        die $message;
    }
    if(!exists($listeners{$event})) {
        ERROR("bad event type <$event>");
        die "bad event type <$event>";
    }
    # generate listener id
    my $id = $currentId;
    $currentId++;
    # save coderef under appropriate event
    $listeners{$event}->{$id} = $code; 
    # save id
    $listenerIds{$id} = $event;
    return $id;
}


sub removeListener {
    my ($id) = @_;
    my $event = $listenerIds{$id};
    if(!defined($event)) {
        die "bad id <$id>";
    }
    # get the right hash
    my $ls = $listeners{$event};
    # sanity check -- this should never happen
    if(!defined($ls->{$id})) {
        die "can't find id in listeners";
    }
    # remove the listener
    delete $ls->{$id};
    # remove the id, too (is this necessary???)
    delete $listenerIds{$id};
}


# parameters:
#   1. event type
#   2. rest args -- these will be passed in order to each listener
sub notify {
    my ($event, @rest) = @_;
    if(!defined($listeners{$event})) {
        die "bad event <$event>";
    }
    my $ls = $listeners{$event};
    INFO("notifying " . scalar(keys %$ls) . " listeners of event <$event>" . 
        " with args <@rest>");
    for my $l (values %$ls) {
        $l->(@rest);
        INFO("listener succeeded");
    }
}


1;