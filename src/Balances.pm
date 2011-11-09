
use strict;
use warnings;


package Balances;
use ComboBox;
use parent qw/WidgetBase/;


sub new {
    my ($class, $parent, $controller) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    $self->{controller} = $controller;
    
    my %info = (text => 'amount',         
        validator => sub { die "bad amount: $_[0]" 
                unless $_[0] =~ /^-?\d+(?:\.\d{0,2})?$/; }
        # a $ amount is an optional '-' sign followed by at least 1 digit,
        #        followed by an optional decimal and up to 0-2 digits 
    );
    $self->{amount} = LabelEntry->new($frame, $info{text}, $info{validator});
    $self->{amount}->g_grid();
    
    $self->{month} = ComboBox->new($frame, 'month', 1,
        $self->{controller}->getMonths(), 0);
    $self->{month}->g_grid();
    
    $self->{year} = ComboBox->new($frame, 'year', 0,
        $self->{controller}->getYears(), 3);
    $self->{year}->g_grid();
    my $currentYear = 2011;
    $self->{year}->setSelected($currentYear);
    
    $self->{account} = ComboBox->new($frame, 'account', 1,
        $self->{controller}->getAccounts(), 0);
    $self->{account}->g_grid();
    
    my $action = sub {
        my $values = {
            year =>     $self->{year}->getSelected(), 
            month =>    $self->{month}->getSelected(),
            account =>  $self->{account}->getSelected()
        };
        my $balance = $self->{controller}->getMonthBalance($values);
        if ($balance) {
            $self->{amount}->setText($balance);
            print "balance set to $balance\n";
        } else { # nothing to do
            print "no balance found\n";
        }
    };
    
    $self->{month}->setAction($action);
    $self->{year}->setAction($action);
    $self->{account}->setAction($action);
    
    $self->createButton();
        
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $self->{controller}->replaceMonthBalance($hashref);#should return 1 or 2
        Tkx::tk___messageBox(-message => "Balance successfully added!");
    };
    
    $self->{frame}->new_ttk__button(-text => 'add balance', 
        -command => $saver)->g_grid(-column => 1, -row => 2, -padx => 10);
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


1;