use strict;
use warnings;

package TransactionRow;
use parent qw/WidgetBase/;
use ComboBox;
use CheckBox;
use Log::Log4perl qw(:easy);



sub new {
    my ($class, $parent, $transaction, $service) = @_;
    my $self = $class->SUPER::new($parent, $service);
    
    $self->{transaction} =  $transaction;
    $self->{isSaved}     =  defined($transaction->getId());
    $self->{service}     =  $service;
    
    $self->_createWidgets();
    $self->_displayButtons();
    $self->_displayEntryWidgets();
    
    return $self;
}


sub _createWidgets {
    my ($self) = @_;
    
    my $frame = $self->{frame};
    my $service = $self->{service};
    
    $self->{save}   = $frame->new_ttk__button(
        -text => 'save transaction', 
        -command => sub {$self->onSavePress();}
    );
    $self->{cancel} = $frame->new_ttk__button(
        -text => 'cancel', 
        -command => sub {$self->onCancelPress();}
    );
    
    $self->{update} = $frame->new_ttk__button(
        -text => 'update transaction', 
        -command => sub {$self->onUpdatePress();}
    );
    $self->{delete} = $frame->new_ttk__button(
        -text => 'delete transaction', 
        -command => sub {$self->onDeletePress();}
    );
    
    $self->{amount} = LabelEntry->new($frame, 'amount');

    $self->{comment} = ComboBox->new(
        $frame, 'comment', 0, 
        $service->getComments(), 0
    );
    
    $self->{date} = LabelEntry->new($frame, 'bank date');
    
    $self->{purchasedate} = LabelEntry->new($frame, 'purchase date');
    
    $self->{account} = ComboBox->new(
        $frame, 'account', 1, 
        $service->getAccounts(), 0
    );
    
    $self->{type} = ComboBox->new(
        $frame, 'transaction type', 1,
        $service->getTransactionTypes(), 0
    );
}


sub _displayEntryWidgets {
    my ($self) = @_;
    
    $self->{amount}->g_grid(       -row => 1, -column => 1);
    $self->{comment}->g_grid(      -row => 1, -column => 2);
    $self->{date}->g_grid(         -row => 1, -column => 3);
    $self->{purchasedate}->g_grid( -row => 1, -column => 4);
    $self->{account}->g_grid(      -row => 1, -column => 5);
    $self->{type}->g_grid(         -row => 1, -column => 6);
}


sub _displayButtons {
    my ($self) = @_;
    if($self->{isSaved}) {
        $self->_displaySavedButtons();
    } else {
        $self->_displayUnsavedButtons();
    }
}


sub _displayUnsavedButtons {
    my ($self) = @_;
    
    $self->{update}->g_grid_remove();
    # more information here:  http://effbot.org/tkinterbook/grid.htm#Tkinter.Grid.grid_forget-method
    # $self->{update}->forget();
    # $self->{delete}->g_pack_forget(); ?????
    # $self->{delete}->forget();
    $self->{delete}->g_grid_remove();
    
    $self->{save}->g_grid(-row => 1, -column => 0);
    $self->{cancel}->g_grid(-row => 2, -column => 1);
}


sub _displaySavedButtons {
    my ($self) = @_;

    $self->{save}->g_grid_remove();
    $self->{cancel}->g_grid_remove();
    
    $self->{update}->g_grid(-row => 1, -column => 0);
    $self->{delete}->g_grid(-row => 2, -column => 1);    
}

########
# button listeners

sub onSavePress {
    
}


sub onCancelPress {
    
}


sub onUpdatePress {
    
}


sub onDeletePress {
    
}

# model listeners

sub onSave {
    my ($self, $status, $id) = @_;
    # don't respond to failure????
    if($status ne 'success') {
        return;
    }
    
    my $isMyId = defined($id) && $id == $self->{transaction}->getId();
    if($isMyId) {
        $self->{isSaved} = 1;
        $self->_displayButtons();
        $self->resetColors();
    }
}


sub onUpdate {
    my ($self, $status, $id) = @_;
    # don't respond to failure????
    if($status ne 'success') {
        return;
    }
    
    my $isMyId = defined($id) && $id == $self->{transaction}->getId();
    if($isMyId) {
        $self->resetColors();
    }
}


#####################

sub resetColors {
    my ($self) = @_;
    my @widgets = (
        $self->{amount},    $self->{comment},
        $self->{date},      $self->{purchasedate},
        $self->{account},   $self->{type}
    );
    for my $w (@widgets) {
        $w->setDefaultColor();
    }
}


1;