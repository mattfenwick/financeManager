use strict;
use warnings;

package Messages;
use Log::Log4perl qw(:easy);
use Data::Dumper;


my %listeners = ();

my %categories = (
    'transaction' => 1,
    'balance' => 1
);

my %subcategories = (
    'save' => 1,
    'update' => 1,
    'delete' => 1
);

my %statuses = (
    'success' => 1,
    'failure' => 1
);


sub addListener {
    my ($code) = @_;
    if(ref($code) ne "CODE") {
        my $message = "need code reference (got <" . ref($code) . ">)";
        ERROR($message);
        die $message;
    }
    # generate and return listener identifier
    my $listenerid = scalar(keys %listeners) + 1;
    $listeners{$listenerid} = $code; 
    return $listenerid;
}


sub removeListener {
    my ($listenerid) = @_;
    my $l = $listeners{$listenerid};
    if(ref($l) eq "CODE") {
        delete $listeners{$listenerid};
    } else {
        die "listener <$listenerid> is not registered";
    }
}


# parameters:
#   1. hashref of event info.  required keys: 'category', 'subcategory', 'status'
#   2. rest args -- these will be passed in order to each listener
sub notify {
    my ($event, @rest) = @_;
    my $category = $event->{category};
    my $subcategory = $event->{subcategory};
    my $status = $event->{status};
    if(!defined($categories{$category})) {
        die "bad event category: <$category>";
    }
    if(!defined($subcategories{$subcategory})) {
        die "bad event subcategory: <$subcategory>";
    }
    if(!defined($statuses{$status})) {
        die "bad event status: <$status>";
    }
    INFO("notifying " . scalar(keys %listeners) . " listeners of event " . 
        Dumper($event) . " with args <@rest>");
    for my $l (values %listeners) {
        $l->(@rest);
        INFO("listener succeeded");
    }
}


1;