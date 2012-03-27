use strict;
use warnings;

package Balances;
use parent qw/WidgetBase/;
use ComboBox;
use Log::Log4perl qw(:easy);

use lib '../model';
use Service;
use Messages;



sub new {
    my ($class, $parent) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    
    my %info = (text => 'amount',         
        validator => sub { die "bad amount: $_[0]" 
                unless $_[0] =~ /^-?\d+(?:\.\d{0,2})?$/; }
        # a $ amount is an optional '-' sign followed by at least 1 digit,
        #        followed by an optional decimal and up to 0-2 digits 
    );
    $self->{amount} = LabelEntry->new($frame, $info{text}, $info{validator});
    $self->{amount}->g_grid();
    
    $self->{month} = ComboBox->new($frame, 'month', 1,
        &Service::getMonths(), 0);
    $self->{month}->g_grid();
    
    $self->{year} = ComboBox->new($frame, 'year', 0,
        &Service::getYears(), 3);
    $self->{year}->g_grid();
    $self->{year}->setSelected(&Service::getCurrentYear());
    
    $self->{account} = ComboBox->new($frame, 'account', 1,
        &Service::getAccounts(), 0);
    $self->{account}->g_grid();
    
    $self->createButton();
    
    $self->addModelListeners();
        
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        &Service::replaceBalance($hashref);
    };
    
    $self->{frame}->new_ttk__button(-text => 'add balance', 
        -command => $saver)->g_grid(-column => 1, -row => 2, -padx => 10);
}


sub resetColors {
    my ($self) = @_;
    $self->{amount}->setDefaultColor();
    $self->{account}->setDefaultColor();
    $self->{year}->setDefaultColor();
    $self->{month}->setDefaultColor();
}


sub getValues {
    my ($self) = @_;
    my %hash = (
        amount =>   $self->{amount}->getText(),
        year =>     $self->{year}->getSelected(), 
        month =>    $self->{month}->getSelected(),
        account =>  $self->{account}->getSelected()
    );
    return \%hash;
}


#############################################################
#### subscribe to model events

sub onSave {
    my ($self, $status) = @_;
    if($status eq "success") {
        Tkx::tk___messageBox(-message => "Balance updated!");
        $self->resetColors();
    } elsif ($status eq "failure") {
        Tkx::tk___messageBox(-message => "Balance could not be updated -- please try again." . 
            "If the problem persists, please notify the maintainers.");
    } else {
        die "bad status: <$status>";
    }
}


sub addModelListeners {
    my ($self) = @_;
    my $c = sub {
        $self->onSave(@_);
    };
    &Messages::addListener("saveBalance", $c);
}


1;