use strict;
use warnings;

package BaseTransaction;
use parent qw/WidgetBase/;
use ComboBox;
use CheckBox;


sub new {
    my ($class, $parent, $service) = @_;
    my $self = $class->SUPER::new($parent);
    $self->{service} = $service;
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
        $service->getComments(), 0);
    $self->{comment}->g_grid();
    
    $self->{date} = LabelEntry->new($frame, 'bank date', sub {1;}, '2012-01-01');
    $self->{date}->g_grid();
    
    $self->{purchasedate} = LabelEntry->new($frame, 'purchase date', sub {1;}, '2012-01-01');
    $self->{purchasedate}->g_grid();
    
    $self->{account} = ComboBox->new($frame, 'account', 1,
        $service->getAccounts(), 0);
    $self->{account}->g_grid();
    
    $self->{type} = ComboBox->new($frame, 'transaction type', 1,
        $service->getTransactionTypes(), 0);
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
        amount              =>  $self->{amount}->getText(),
        account             =>  $self->{account}->getSelected(),
        date                =>  $self->{date}->getText(),
        purchasedate        =>  $self->{purchasedate}->getText(),
        comment             =>  $self->{comment}->getSelected(),
        isbankconfirmed     =>  $self->{isBankConfirmed}->isChecked(),
        isreceiptconfirmed  =>  $self->{isReceipt}->isChecked(),
        type                =>  $self->{type}->getSelected()
    );
    return \%hash;
}


sub resetColors {
    my ($self) = @_;
    my @widgets = (
        $self->{amount},    $self->{comment},
        $self->{date},      $self->{purchasedate},
        $self->{account},   $self->{type}, 
        $self->{isReceipt}, $self->{isBankConfirmed}
    );
    for my $w (@widgets) {
        $w->setDefaultColor();
    }
}


1;