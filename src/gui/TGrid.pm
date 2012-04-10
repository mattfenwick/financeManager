use strict;
use warnings;

package TGrid;
use parent qw/WidgetBase/;
use ComboBox;
use LabelEntry;
use ResultViewer;
use Log::Log4perl qw(:easy);
use Try::Tiny;


# determine the order that fields should show up in
#   determine how they should be displayed
#   determine what their display names should be
my @fields = (
    ['id', ],
    ['date', 'bank date', sub {return $_[0]->toYMD();}],
    ['account', 'account', sub {return $_[0];}],
    # etc. ...
    ['isreceiptconfirmed', 'have receipt', 
        sub {if($_[0]) {return "yes";} else {return "no";}}]
);


sub new {
    my ($class, $parent, $service) = @_;
    my $self = $class->SUPER::new($parent);
    $self->{service} = $service;
    my $frame = $self->{frame};

    $self->{parent} = $parent; # save reference to parent to be able to add menu
    
    $self->{year} = ComboBox->new($frame, 'select bank year', 1,
            ["all", @{$service->getYears()}], 0);
    $self->{month} = ComboBox->new($frame, 'select bank month', 1,
            ["all", @{$service->getMonths()}], 0);
    $self->{account} = ComboBox->new($frame, 'select account', 1,
            ["all", @{$service->getAccounts()}], 0);
    $self->{comment} = ComboBox->new($frame, 'select comment', 1,
            ["all", @{$service->getComments()}], 0);
    $self->{amountlow} = LabelEntry->new($frame, 'select low amount', sub {1}, 0.01);
    $self->{amounthigh} = LabelEntry->new($frame, 'select high amount', sub {1}, 10000);
    
            
    $self->{viewer} = ResultViewer->new($frame);

    $self->{showTransactions} = $frame->new_ttk__button(-text => 'show transactions', 
        -command => sub { $self->showTransactions(); } );
    
    $self->layoutWidgets();
    
    return $self;
}


sub getTransactions {
    my ($self) = @_;
    $self->{transactions} = $self->{service}->getAllTransactions();
}


sub filterTransactions {
    my ($self, @trans) = @_;
    my $year = $self->{year}->getSelected();
    my $month = $self->{month}->getSelected();
    my $account = $self->{account}->getSelected();
    my $lo = $self->{amountlow}->getText();
    my $hi = $self->{amounthigh}->getText();
    
    INFO("found " . scalar(@trans) . " rows");
    my @filt1;
    if($year eq "all") {
        @filt1 = @trans;
    } else {
        @filt1 = &filter(sub {return $_[0]->{date}->{year} == $year;}, @trans);
    }
    INFO("down to " . scalar(@filt1) . " rows after first filter");
    my @filt2;
    if($month eq "all") {
        @filt2 = @filt1;
    } else {
        @filt2 = &filter(sub {return $_[0]->{date}->{month} == $month;}, @filt1);        
    }
    INFO("down to " . scalar(@filt2) . " rows after second filter");
    
    my @filt3;
    if($account eq "all") {
        @filt3 = @filt2;
    } else {
        @filt3 = &filter(sub {return $_[0]->{account} eq $account}, @filt2);
    }
    INFO("down to " . scalar(@filt3) . " rows after third filter");
    
    my @filt4 = &filter(sub {
        return ($_[0]->{amount} >= $lo && $_[0]->{amount} <= $hi);
    }, @filt3);
    
    return @filt4;
}


sub showTransactions {
    my ($self) = @_;

    if(!$self->{transactions}) {
        $self->getTransactions();
    }
    
    my @trans = @{$self->{transactions}};
    
    my @filts = $self->filterTransactions(@trans);
    
    my @heads = keys %{$trans[0]};
    my @fRows = ();
    for my $row (@filts) {
        my @arrRow = ();
        for my $key (@heads) {
            my $val = $row->{$key};
            if(ref($val) eq "Date") {
                push(@arrRow, $val->toYMD());
            } else {            
                push(@arrRow, $val);
            }
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
    $self->{amountlow}->g_grid(-row => 3, -column => 0);
    $self->{amounthigh}->g_grid(-row => 4, -column => 0);
    $self->{showTransactions}->g_grid(-row => 5, -column => 0);
    
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
