use strict;
use warnings;

package EditTransaction;
use parent qw/AddTransaction/;
use ComboBox;


sub new {
    my ($class, $parent, $controller) = @_;
    my $self = $class->SUPER::new($parent, $controller);
    
    $self->{selector} = ComboBox->new($self->{frame}, 'select id', 1,
        $self->{controller}->getIDs);
    $self->{selector}->g_grid(-row => 1, -column => 1);
    $self->{selector}->setAction(
        sub { 
            my ($id) = @_;
            $self->displayTransaction($id); 
        }
    );
    
    $self->{updateIDs} = $self->{frame}->new_ttk__button(-text => "Fetch new transactions",
        -command => sub { 
                $self->{selector}->setValues($self->{controller}->getIDs()); 
                Tkx::tk___messageBox(-message => "Transactions fetched!");
            }  
        );
    $self->{updateIDs}->g_grid(-row => 0, -column => 1);
    
    return $self;
}


sub createButton { # overrides AddTransaction's method
    my ($self) = @_;
        
    my $saver = sub {
        my $hashref = $self->getValues();
        $hashref->{id} = $self->{selector}->getSelected();
        $self->{controller}->updateTransaction($hashref); # should return 1
        Tkx::tk___messageBox(-message => "Transaction successfully updated!");
        $self->{comment}->setValues($self->{controller}->getComments());
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
        warn "delete continue result: $continue";
        if ($continue eq "yes") {
            $self->{controller}->deleteTransaction($id); # should return 1
            Tkx::tk___messageBox(-message => "Transaction successfully deleted!");        
            $self->{selector}->setValues($self->{controller}->getIDs);
            $self->{selector}->setSelectedIndex(0);
        } else {
            # nothing to do
        }
    };
    $self->{frame}->new_ttk__button(-text => 'delete transaction',
        -command => $command)->g_grid(-row => 4, -column => 1);
}


sub displayTransaction {
    my ($self, $id) = @_;
    use Data::Dumper;
    my $result = $self->{controller}->getTransaction($id);
    print Dumper($result);
    $self->{comment}->setSelected($result->{comment});
    $self->{account}->setSelected($result->{account});
    $self->{year}->setSelected($result->{year});
    $self->{month}->setSelected($result->{month});
    $self->{day}->setSelected($result->{day});
    $self->{amount}->setText($result->{amount});
    $self->{isReceipt} = $result->{isreceiptconfirmed};
    $self->{isBankConfirmed} = $result->{isbankconfirmed};
    $self->{type}->setSelected($result->{type});
}


1;