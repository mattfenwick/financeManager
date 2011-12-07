use strict;
use warnings;

package AddTransaction;
use parent qw/BaseTransaction/;


sub new {
    my ($class, $parent, $controller) = @_;
    my $self = $class->SUPER::new($parent, $controller);
    
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $self->{controller}->addTransaction($hashref);# return value should be 1
        Tkx::tk___messageBox(-message => "Transaction successfully added!");
        $self->{comment}->setValues($self->{controller}->getComments());
        $self->resetColors();
    };
    
    $self->{frame}->new_ttk__button(-text => 'save transaction', 
        -command => $saver)->g_grid(-row => 2, -column => 1);
}


sub resetColors {
    my ($self) = @_;
    $self->{amount}->setDefaultColor();
    $self->{comment}->setDefaultColor();
    $self->{year}->setDefaultColor();
    $self->{month}->setDefaultColor();
    $self->{day}->setDefaultColor();
    $self->{account}->setDefaultColor();
    $self->{type}->setDefaultColor();
    $self->{isReceipt}->setDefaultColor();
    $self->{isBankConfirmed}->setDefaultColor();
}

1;