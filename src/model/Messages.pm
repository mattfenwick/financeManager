use strict;
use warnings;

package Messages;
use Log::Log4perl qw(:easy);



sub new {
    my ($class) = @_;
    my $self = {
        listenerIds => {},
        listeners   => {
            'saveTransaction'   => {},
            'updateTransaction' => {},
            'deleteTransaction' => {},
            'saveBalance'       => {}
        },
        currentId   => 1
    };
    bless($self, $class);
    return $self;
}


sub addListener {
    my ($self, $event, $code) = @_;
    if(ref($code) ne "CODE") {
        my $message = "need code reference (got <" . ref($code) . ">)";
        ERROR($message);
        die $message;
    }
    if(!exists($self->{listeners}->{$event})) {
        ERROR("bad event type <$event>");
        die "bad event type <$event>";
    }
    # generate listener id
    my $id = $self->{currentId};
    $self->{currentId}++;
    # save coderef under appropriate event
    $self->{listeners}->{$event}->{$id} = $code; 
    # save id
    $self->{listenerIds}->{$id} = $event;
    return $id;
}


sub removeListener {
    my ($self, $id) = @_;
    my $event = $self->{listenerIds}->{$id};
    if(!defined($event)) {
        die "bad id <$id>";
    }
    # get the right hash
    my $ls = $self->{listeners}->{$event};
    # sanity check -- this should never happen
    if(!defined($ls->{$id})) {
        die "can't find id in listeners";
    }
    # remove the listener
    delete $ls->{$id};
    # remove the id, too (is this necessary???)
    delete $self->{listenerIds}->{$id};
}


# parameters:
#   1. event type
#   2. rest args -- these will be passed in order to each listener
sub notify {
    my ($self, $event, @rest) = @_;
    if(!defined($self->{listeners}->{$event})) {
        die "bad event <$event>";
    }
    my $ls = $self->{listeners}->{$event};
    INFO("notifying " . scalar(keys %$ls) . " listeners of event <$event>" . 
        " with args <@rest>");
    for my $l (values %$ls) {
        $l->(@rest);
        INFO("listener succeeded");
    }
}


1;