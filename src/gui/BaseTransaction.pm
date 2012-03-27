use strict;
use warnings;

package BaseTransaction;
use parent qw/WidgetBase/;
use ComboBox;
use CheckBox;

use lib '../model';
use Service;


sub new {
    my ($class, $parent) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    
    my %info = (text => 'amount',         
        validator => sub { die "bad amount: $_[0]" 
                unless $_[0] =~ /^\d+(?:\.\d{0,2})?$/; }
        # a $ amount is at least 1 digit,
        #        followed by an optional decimal and up to 0-2 digits 
    );
    $self->{amount} = LabelEntry->new($frame, $info{text}, $info{validator});
    $self->{amount}->g_grid();

    $self->{comment} = ComboBox->new($frame, 'comment', 0,
        &Service::getComments(), 0);
    $self->{comment}->g_grid();
    
    $self->{year} = ComboBox->new($frame, 'year', 0,
        &Service::getYears(), 0);
    $self->{year}->setSelected(&Service::getCurrentYear());
    $self->{year}->g_grid();
    
    $self->{month} = ComboBox->new($frame, 'month', 1,
        &Service::getMonths(), 0);
    $self->{month}->g_grid();
    
    $self->{day} = ComboBox->new($frame, 'day', 1,
        &Service::getDays(), 1);
    $self->{day}->g_grid();
    
    $self->{account} = ComboBox->new($frame, 'account', 1,
        &Service::getAccounts(), 0);
    $self->{account}->g_grid();
    
    $self->{type} = ComboBox->new($frame, 'transaction type', 1,
        &Service::getTransactionTypes(), 0);
    $self->{type}->g_grid();
    
    $self->{isReceipt} = 0;
    $self->{isBankConfirmed} = 0;
    
    $self->{isReceipt} = CheckBox->new($frame, 'have receipt for transaction');
    $self->{isReceipt}->g_grid();
    $self->{isBankConfirmed} = CheckBox->new($frame, 'bank confirms transaction');
    $self->{isBankConfirmed}->g_grid();
    
    $self->createButton();
    
    $self->addModelListeners();
    
    return $self;
}


sub getValues {
    my ($self) = @_;
    my %hash = (
        amount  =>  $self->{amount}->getText(),
        account =>  $self->{account}->getSelected(),
        date    =>  join('-', $self->{year}->getSelected(), 
                        $self->{month}->getSelected(), $self->{day}->getSelected()), 
        comment =>  $self->{comment}->getSelected(),
        bank    =>  $self->{isBankConfirmed}->isChecked(),
        receipt =>  $self->{isReceipt}->isChecked(),
        type    =>  $self->{type}->getSelected()
    );
    return \%hash;
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