use strict;
use warnings;

package TransactionGrid;
use parent qw/WidgetBase/;
use ComboBox;
use CheckBox;
use Log::Log4perl qw(:easy);



sub new {
    my ($class, $parent, $service) = @_;
    my $self = $class->SUPER::new($parent, $service);
    
    $self->_createControls();
    $self->_createGrid();

    $self->_displayControls();
    $self->_displayGrid();
    
    return $self;
}


sub _createControls {
    my ($self) = @_;
    
    my $frame = $self->{frame};
    
    $self->{sortFilter} = $frame->new_ttk__button(
        -text => 'sort & filter', 
        -command => sub {$self->onSortFilterPress();}
    );
}


sub onSortFilterPress {
    my ($self) = @_;
    if($self->_checkPreconditions()) {
        # do some stuff
    } else {
        # complain
    }
}


sub _checkPreconditions {
    my ($self) = @_;
    # no Rows with unsaved changes
}


sub _createGrid {
    my ($self) = @_;
    my $gFrame = $self->{frame}->new_frame(); # height?  width?
}


sub createRow {
    my ($self) = @_;
    # get a new, default Transaction
    # create a new TransactionRow
    # place the TransactionRow
}


sub deleteRow {
    
}


1;