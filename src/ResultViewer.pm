use strict;
use warnings;


package ResultViewer;
use parent qw/WidgetBase/;

####### public methods
#    displayResults (self, hash: keys: 'headings' and 'rows')
#    g_grid (self, options)
#
####### private methods
#    addScrollBar (self)
#    clearResults (self)
#    sortResults (self)

my $DEFAULT_COLOR = "green";


sub new {
    my ($class, $parent) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    my $tree = $frame->new_ttk__treeview(-height => 25);
    $self->{tree} = $tree;
    $self->{itemids} = [];
    $self->{scrollbar} = $frame->new_ttk__scrollbar(-orient => 'vertical', 
            -command => [$tree, 'yview']);
    $self->setupWidgets();
    $self->setRowColor($DEFAULT_COLOR);
    return $self;
}


sub setRowColor {
    my ($self, $color) = @_;
    $self->{tree}->tag_configure("colortag", -background => $color); # new
}


sub displayResults {
    my ($self, $headings, $rows) = @_;
    $self->clearResults();
    my ($tree) = $self->{tree};
    my @headings = @$headings;
    my @rows = @$rows;
    $tree->configure(-columns => [@headings[1..$#headings]]);
    $tree->heading("#0", -text => $headings[0], -command => sub {$self->sortResults(0)});
    $tree->column("#0", -width => 100, -minwidth => 100);
    for my $index (1..$#headings) {
        my $head = $headings[$index];
        my $command = sub {
            $self->sortResults($index);
        };
        $tree->heading($head, -text => $head, -command => $command);
        $tree->column($head, -width => 100, -minwidth => 100);
    }
    
    $self->addRows(@rows);
    
    $self->{headings} = $headings;
}


sub addRows {
    my ($self, @rows) = @_;
    my @ids = ();
    my $index = 0;
    my $tree = $self->{tree};
    for my $row (@rows) {
        my @row = @$row;
        my $id;
        if ($index % 2 == 0) {
            $id = $tree->insert("", "0", -text => $row[0], -values => [@row[1..$#row]]);        
        } else {
            $id = $tree->insert("", "0", -text => $row[0], -values => [@row[1..$#row]],
                -tags => "colortag"); # new
            #print "damn $id  ";
        }
        $index++;
        push(@ids, $id);
    }
    $self->{itemids} = [@ids];
    $self->{rows} = [@rows];
}


sub clearResults {
    my ($self) = @_;
    my @ids = @{$self->{itemids}};
    for my $id (@ids) {
        $self->{tree}->delete($id);
    }
    $self->{headings} = [];
    $self->{rows} = [];
}


sub setupWidgets {
    my ($self) = @_;
    my $tree = $self->{tree};
    my $scrollbar = $self->{scrollbar};
    $tree->configure(-yscrollcommand => [$scrollbar, 'set']);
    
    $self->{frame}->g_grid_columnconfigure(1, -weight => 1);
    $self->{frame}->g_grid_rowconfigure(0, -weight => 1);
    
    my $xscroll = $self->{frame}->new_ttk__scrollbar(-orient => 'horizontal', 
            -command => [$tree, 'xview']);
    $tree->configure(-xscrollcommand => [$xscroll, 'set']);
    $xscroll->g_grid(-row => 1, -column => 1, -sticky => 'ew');
    
    $scrollbar->g_grid(-row => 0, -column => 0, -sticky => 'ns');
    $tree->g_grid(-row => 0, -column => 1, -sticky => 'nsew');
#    my $xscroll = $self->{xscroll};
#    $tree->configure(-xscrollcommand => [$xscroll, 'set']);
#    $xscroll->g_grid(-row => 1, -column => 1, -sticky => 'ew');
#    $self->{frame}->g_grid_columnconfigure(0, -weight => 1);
#    $self->{frame}->g_grid_columnconfigure(1, -weight => 1);
}


sub sortResults {
    my ($self, $column) = @_;
#    my @headings = @{$self->{headings}};
    my @rows = @{$self->{rows}};
    my @sorted = sort 
        {
            abs($b->[$column]) <=> abs($a->[$column])
            || uc($b->[$column]) cmp uc($a->[$column])
        } 
        @rows;
#    $self->displayResults([@headings], [@sorted]);
    $self->clearResults();
    print "in sort: " . scalar(@sorted) . " rows;  args: @_\n";
    $self->addRows(@sorted);
}


1;