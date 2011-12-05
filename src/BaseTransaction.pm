use strict;
use warnings;

package AddTransaction;
use parent qw/WidgetBase/;


sub new {
    my ($class, $parent, $controller) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    $self->{controller} = $controller;
    
    my %info = (text => 'amount',         
        validator => sub { die "bad amount: $_[0]" 
                unless $_[0] =~ /^\d+(?:\.\d{0,2})?$/; }
        # a $ amount is at least 1 digit,
        #        followed by an optional decimal and up to 0-2 digits 
    );
    $self->{amount} = LabelEntry->new($frame, $info{text}, $info{validator});
    $self->{amount}->g_grid();

    $self->{comment} = ComboBox->new($frame, 'comment', 0,
        $self->{controller}->getComments(), 0);
    $self->{comment}->g_grid();
    
    $self->{year} = ComboBox->new($frame, 'year', 0,
        $self->{controller}->getYears(), 0);
    my $currentYear = 2011;
    $self->{year}->setSelected($currentYear);
    $self->{year}->g_grid();
    
    $self->{month} = ComboBox->new($frame, 'month', 1,
        $self->{controller}->getMonths(), 0);
    $self->{month}->g_grid();
    
    $self->{day} = ComboBox->new($frame, 'day', 1,
        $self->{controller}->getDays(), 1);
    $self->{day}->g_grid();
    
    $self->{account} = ComboBox->new($frame, 'account', 1,
        $self->{controller}->getAccounts(), 0);
    $self->{account}->g_grid();
    
    $self->{type} = ComboBox->new($frame, 'transaction type', 1,
        $self->{controller}->getTransactionTypes(), 0);
    $self->{type}->g_grid();
    
    $self->{isReceipt} = 0;
    $self->{isBankConfirmed} = 0;
    $frame->new_ttk__checkbutton(-text => 'have receipt for transaction',
        -variable => \$self->{isReceipt})->g_grid(-pady => 5);
    $frame->new_ttk__checkbutton(-text => 'bank confirms transaction',
        -variable => \$self->{isBankConfirmed})->g_grid(-pady => 5);
        
    $self->createButton();
    
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $self->{controller}->addTransaction($hashref);# return value should be 1
        Tkx::tk___messageBox(-message => "Transaction successfully added!");
        $self->{comment}->setValues($self->{controller}->getComments());
    };
    
    $self->{frame}->new_ttk__button(-text => 'save transaction', 
        -command => $saver)->g_grid(-row => 2, -column => 1);
}


sub getValues {
    my ($self) = @_;
    my %hash = (
        amount  =>  $self->{amount}->getText(),
        account =>  $self->{account}->getSelected(),
        date    =>  join('-', $self->{year}->getSelected(), 
                        $self->{month}->getSelected(), $self->{day}->getSelected()), 
        comment =>  $self->{comment}->getSelected(),
        bank    =>  $self->{isBankConfirmed},
        receipt =>  $self->{isReceipt},
        type    =>  $self->{type}->getSelected()
    );
    return \%hash;
}


1;