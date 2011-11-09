
use strict;
use warnings;


package Reports;
use ComboBox;
use ResultViewer;
use parent qw/WidgetBase/;

############### description
#    a frame with:
#        a ComboBox for selecting a report
#        a button for grabbing the report from the database and displaying it
#        a button for saving the current report to file
#            'die's if no report selected yet
#            bails if no file selected
#            'die's if can't open file (for whatever reason)
#            'die's if can't close file -- unknown result in this case
#            otherwise, notifies success
#        a ResultViewer for displaying the report


sub new {
    my ($class, $parent, $controller) = @_;
    my $self = $class->SUPER::new($parent);
    $self->{controller} = $controller;
    my $frame = $self->{frame};
    
    $self->{cbox} = ComboBox->new($frame, 'Select report', 1,
            $controller->getAvailableReports(), 0);
            
    $self->{viewer} = ResultViewer->new($frame);

    $self->{displayReport} = $frame->new_ttk__button(-text => 'Display report', 
        -command => sub { $self->fetchAndDisplayReport();} );
        
    $self->{saveReport} = $frame->new_ttk__button(-text => 'Save report',
        -command => sub {$self->saveReport();} );
        
    $self->{colorChooser} = $frame->new_ttk__button(-text => 'Select row color',
        -command => sub {$self->chooseColor();} );
        
    $self->{haveReport} = 0;
    
    $self->layoutWidgets();
    return $self;
}


sub layoutWidgets {
    my ($self) = @_;
    my ($frame) = $self->{frame};

    $frame->g_grid_columnconfigure(1, -weight => 1);
    $frame->g_grid_rowconfigure(2, -weight => 1);

    $self->{cbox}->g_grid(-row => 0, -column => 0);
    $self->{displayReport}->g_grid(-row => 1, -column => 0, -sticky => 'ew');
    $self->{saveReport}->g_grid(-row => 2, -column => 0, -sticky => 'ew');
    $self->{colorChooser}->g_grid(-row => 3, -column => 0, -sticky => 'ew');# new
    $self->{viewer}->g_grid(-row => 2, -column => 1, -rowspan => 30, -sticky => 'nsew');
}


sub fetchAndDisplayReport {
    my ($self) = @_;
    print "selected: " . $self->{cbox}->getSelected() . "\n";
    my ($headings, $rows) = $self->{controller}->getReport(
        {query => $self->{cbox}->getSelected()}
    );
    $self->{viewer}->displayResults($headings, $rows);
    $self->{headings} = $headings;
    $self->{rows} = $rows;
    $self->{haveReport} = 1;
}


sub saveReport {
    my ($self) = @_;
    die "no report to save" unless $self->{haveReport};
    my $filename = Tkx::tk___getSaveFile();
    return unless $filename;
    open(my $file, ">$filename") || die "can't open file $filename for writing";
    my $headline = join("\t", @{$self->{headings}});
    print $file "$headline\n";
    for my $row (@{$self->{rows}}) {
        my $line = join("\t", @$row);
        print $file "$line\n";
    }
    close($file) || die "problem closing file $filename:  ";
    Tkx::tk___messageBox(-message => "Report saved");
}


sub chooseColor {
    my ($self) = @_;
    my $color = Tkx::tk___chooseColor(-initialcolor => "#ff0000");
    if ($color) {
        $self->{viewer}->setRowColor($color);
    }
}


1;
