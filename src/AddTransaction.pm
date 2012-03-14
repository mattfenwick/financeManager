use strict;
use warnings;

package AddTransaction;
use parent qw/BaseTransaction/;


sub new {
    my ($class, $parent, $model) = @_;
    my $self = $class->SUPER::new($parent, $model);
    
    return $self;
}


sub addModelListeners {
    my ($self) = @_;
    my $callback = sub {
        my ($status) = @_;
        if($status eq "success") {        	
            Tkx::tk___messageBox(-message => "Transaction successfully added!");
            $self->{comment}->setValues($self->{model}->getComments());
            $self->resetColors();
        } elsif($status eq "failure") {
            Tkx::tk___messageBox(-message => "Transaction could not be added -- please try again." . 
                "If the problem persists, please notify the maintainers.");
        } else {
        	die "invalid status: <$status>";
        }
    };
    $self->{model}->addListener("saveTrans", $callback);
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $self->{model}->addTransaction($hashref);
    };
    
    $self->{frame}->new_ttk__button(-text => 'save transaction', 
        -command => $saver)->g_grid(-row => 2, -column => 1);
}


sub resetColors {
    my ($self) = @_;
    my @widgets = (
        $self->{amount}, $self->{comment},
        $self->{year}, $self->{month},
        $self->{day}, $self->{account},
        $self->{type}, $self->{isReceipt},
        $self->{isBankConfirmed}
    );
    for my $w (@widgets) {
        $w->setDefaultColor();
    }
}

1;