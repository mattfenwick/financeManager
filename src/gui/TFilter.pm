use strict;
use warnings;

package TFilter;
use parent qw/WidgetBase/;
use ComboBox;
use ResultViewer;
use Log::Log4perl qw(:easy);
use Try::Tiny;


sub new {
    my ($class, $parent, $service) = @_;
    my $self = $class->SUPER::new($parent);
    $self->{service} = $service;
    my $frame = $self->{frame};

    $self->{parent} = $parent; # save reference to parent to be able to add menu
    
    $self->{year} = ComboBox->new($frame, 'select year', 1,
            ["all", @{$service->getYears()}], 0);
    $self->{month} = ComboBox->new($frame, 'select month', 1,
            ["all", @{$service->getMonths()}], 0);
    $self->{account} = ComboBox->new($frame, 'select account', 1,
            ["all", @{$service->getAccounts()}], 0);
            
    $self->{viewer} = ResultViewer->new($frame);

    $self->{showTransactions} = $frame->new_ttk__button(-text => 'show transactions', 
        -command => sub { $self->showTransactions(); } );
    
    $self->layoutWidgets();
    
    return $self;
}


sub getTransactions {
    my ($self) = @_;
    if(!$self->{transactions}) {
        my @trans = ();
        my $ids = $self->{service}->getIDs();
        for my $id (@$ids) {
            my $t = $self->{service}->getTransaction($id);
            push(@trans, $t);
        }
        $self->{transactions} = \@trans;
    }
}


sub showTransactions {
    my ($self) = @_;
    my $year = $self->{year}->getSelected();
    my $month = $self->{month}->getSelected();
    my $account = $self->{account}->getSelected();
    
    my @trans = @{$self->{transactions}};
#    my $rep = $self->{service}->getReport('transactions');
#    my $trans = $rep->getDictRows();

    INFO("found " . scalar(@trans) . " rows");
    my @filt1;
    if($year eq "all") {
        @filt1 = @trans;
    } else {
        @filt1 = &filter(sub {return $_[0]->{year} == $year;}, @trans);
    }
    INFO("down to " . scalar(@filt1) . " rows after first filter");
    my @filt2;
    if($month eq "all") {
        @filt2 = @filt1;
    } else {
        @filt2 = &filter(sub {return $_[0]->{month} == $month;}, @filt1);        
    }
    INFO("down to " . scalar(@filt2) . " rows after second filter");
    
    my @filt3;
    if($account eq "all") {
        @filt3 = @filt2;
    } else {
        @filt3 = &filter(sub {return $_[0]->{account} eq $account}, @filt2);
    }
    INFO("down to " . scalar(@filt3) . " rows after third filter");
    
    my @heads = keys %{$trans[0]};
    my @fRows = ();
    for my $row (@filt3) {
        my @arrRow = ();
        for my $key (@heads) {
            push(@arrRow, $row->{$key});
        }
        push(@fRows, \@arrRow);
    }
    
    $self->{viewer}->displayResults(\@heads, \@fRows);
    $self->resetColors();
}


sub resetColors {
    my ($self) = @_;
    my @ws = qw/account year month/;
    for my $w (@ws) {
        $self->{$w}->setDefaultColor();
    }
}


sub cleanUp {
    my ($self) = @_;
    my $gui = $self->{parent};
    my @ids = @{$self->{listenerIds}};
    INFO("cleaning up reports window -- removing " . scalar(@ids) . " listeners");
    for my $id (@ids) {
        $self->{service}->removeListener($id);
    }
    $gui->Tkx::destroy();
}


sub layoutWidgets {
    my ($self) = @_;
    my ($frame) = $self->{frame};

    $frame->g_grid_columnconfigure(1, -weight => 1);
    $frame->g_grid_rowconfigure(2, -weight => 1);

    $self->{year}->g_grid(-row => 0, -column => 0);
    $self->{month}->g_grid(-row => 1, -column => 0);
    $self->{account}->g_grid(-row => 2, -column => 0);
    $self->{showTransactions}->g_grid(-row => 3, -column => 0);
    
    $self->{viewer}->g_grid(-row => 0, -column => 1, -rowspan => 30, -sticky => 'nsew');
}


sub filter {
    my ($func, @trans) = @_;
    my @out = ();
    for my $tran (@trans) {
        if($func->($tran)) {
            push(@out, $tran);
        }
    }
    return @out;
}

1;
