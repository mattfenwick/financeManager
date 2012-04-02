use strict;
use warnings;

package AddTransaction;
use parent qw/BaseTransaction/;
use Log::Log4perl qw(:easy);



sub new {
    my ($class, $parent, $service) = @_;
    my $self = $class->SUPER::new($parent);
    $self->{service} = $service;
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $self->{service}->saveTransaction($hashref);
    };
    
    $self->{frame}->new_ttk__button(-text => 'save transaction', 
        -command => $saver)->g_grid(-row => 2, -column => 1);
}


#########################################
#### subscribe to model events

sub onSave {
    my ($self, $status, $message) = @_;
    if($status eq "success") {          
        Tkx::tk___messageBox(-message => "Transaction successfully added!");
        $self->{comment}->setValues($self->{service}->getComments());
        $self->resetColors();
    } elsif($status eq "failure") {
        Tkx::tk___messageBox(-message => "Transaction could not be added: $message"); 
    } else {
        ERROR("invalid status: <$status>");
        die "invalid status: <$status>";
    }
};


sub addModelListeners {
    my ($self) = @_;
    my $callback = sub {
    	$self->onSave(@_);
    };
    $self->{service}->addListener("saveTransaction", $callback);
}

1;