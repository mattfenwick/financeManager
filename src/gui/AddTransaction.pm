use strict;
use warnings;

package AddTransaction;
use parent qw/BaseTransaction/;

use lib '../model';
use Service;
use Messages;


sub new {
    my ($class, $parent) = @_;
    my $self = $class->SUPER::new($parent);
    
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        &Service::saveTransaction($hashref);
    };
    
    $self->{frame}->new_ttk__button(-text => 'save transaction', 
        -command => $saver)->g_grid(-row => 2, -column => 1);
}


#########################################
#### subscribe to model events

sub onSave {
    my ($self, $status) = @_;
    if($status eq "success") {          
        Tkx::tk___messageBox(-message => "Transaction successfully added!");
        $self->{comment}->setValues(&Service::getComments());
        $self->resetColors();
    } elsif($status eq "failure") {
        Tkx::tk___messageBox(-message => "Transaction could not be added -- please try again." . 
            "If the problem persists, please notify the maintainers.");
    } else {
        die "invalid status: <$status>";
    }
};


sub addModelListeners {
    my ($self) = @_;
    my $callback = sub {
    	$self->onSave(@_);
    };
    &Messages::addListener("saveTrans", $callback);
}

1;