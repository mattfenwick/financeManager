use strict;
use warnings;

package EditTransaction;
use parent qw/BaseTransaction/;
use ComboBox;
use Log::Log4perl qw(:easy);

use lib '../model';
use Service;
use Messages;


sub new {
    my ($class, $parent) = @_;
    my $self = $class->SUPER::new($parent);
    
    $self->{selector} = ComboBox->new($self->{frame}, 'select id', 1,
        &Service::getIDs);
    $self->{selector}->g_grid(-row => 1, -column => 1);
    $self->{selector}->setAction(
        sub { 
            my ($id) = @_;
            $self->setValues($id);
            $self->resetColors();
        }
    );
    
    return $self;
}


sub createButton {
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $hashref->{id} = $self->{selector}->getSelected();
        &Service::updateTransaction($hashref);
    };
    
    $self->{frame}->new_ttk__button(-text => 'update transaction', 
        -command => $saver)->g_grid(-row => 2, -column => 1);
        
    $self->deleteButton();
}


sub deleteButton {
    my ($self) = @_;
    my $command = sub {
        my $id = $self->{selector}->getSelected();
        # ask for confirmation
        my $continue = Tkx::tk___messageBox(-type => "yesno",
            -message => "Are you sure you want to delete this transaction?",
            -icon => "question", -title => "Delete transaction");
        if ($continue eq "yes") {
            WARN("deleting transaction <$id>");
            &Service::deleteTransaction($id);
        } else {
            # nothing to do
        }
    };
    $self->{frame}->new_ttk__button(-text => 'delete transaction',
        -command => $command)->g_grid(-row => 3, -column => 1);
}


sub setValues {
    my ($self, $id) = @_;
    my $result = &Service::getTransaction($id);

    $self->{comment}->setSelected($result->{comment});
    $self->{account}->setSelected($result->{account});
    $self->{year}->setSelected($result->{year});
    $self->{month}->setSelected($result->{month});
    $self->{day}->setSelected($result->{day});
    $self->{amount}->setText($result->{amount});
    $self->{isReceipt}->setChecked($result->{isreceiptconfirmed});
    $self->{isBankConfirmed}->setChecked($result->{isbankconfirmed});
    $self->{type}->setSelected($result->{type});
}


######################################3
#### subscribing to model events

sub onDelete {
    my ($self, $status, $message) = @_;
    if($status eq "success") {
        Tkx::tk___messageBox(-message => "Transaction successfully deleted!");      
        $self->{selector}->setValues(&Service::getIDs);
        $self->{selector}->setSelectedIndex(0);             # make combobox selection valid
        $self->setValues($self->{selector}->getSelected()); # and set widgets
        $self->resetColors();                               # reset widget colors
    } elsif($status eq "failure") {
        Tkx::tk___messageBox(-message => "Transaction could not be deleted: $message");
    } else {
        ERROR("invalid status: <$status>");
        die "invalid status: <$status>";
    }
}


sub onEdit {
    my ($self, $status, $message) = @_;
    if($status eq "success") {
        Tkx::tk___messageBox(-message => "Transaction successfully updated!");
        $self->{comment}->setValues(&Service::getComments());
        $self->resetColors();
    } elsif($status eq "failure") {
        Tkx::tk___messageBox(-message => "Transaction could not be updated: $message");
    } else {
        ERROR("invalid status: <$status>");
        die "invalid status: <$status>";
    }
}


sub onNewIds {
	my ($self, $status) = @_;
    if($status eq "success") {
        $self->{selector}->setValues(&Service::getIDs());
        INFO("ids updated");
    } elsif($status eq "failure") {
        # no change in ids -> nothing to do
    } else {
        ERROR("invalid status: <$status>");
        die "invalid status: <$status>";
    }
}


sub addModelListeners {
    my ($self) = @_;
    my $edit = sub {
        $self->onEdit(@_);
    };
    &Messages::addListener("editTransaction", $edit);
    
    my $del = sub {
        $self->onDelete(@_);
    };
    &Messages::addListener("deleteTransaction", $del);
    
    my $newIds = sub {
    	$self->onNewIds(@_);
    };
    &Messages::addListener("saveTransaction", $newIds);
}


1;