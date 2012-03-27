use strict;
use warnings;

package Reports;
use parent qw/WidgetBase/;
use ComboBox;
use ResultViewer;
use Log::Log4perl qw(:easy);

use lib '../model';
use Service;
use Messages;


############### description
#    a toplevel window with:
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
    my ($class, $parent) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};

    $self->{parent} = $parent; # save reference to parent to be able to add menu
    
    $self->{cbox} = ComboBox->new($frame, 'Select report', 1,
            &Service::getAvailableReports(), 0);
            
    $self->{viewer} = ResultViewer->new($frame);

    $self->{displayReport} = $frame->new_ttk__button(-text => 'Display report', 
        -command => sub { $self->fetchAndDisplayReport();} );
        
    $self->{report} = 0;
    
    $self->makeMenu();
    $self->layoutWidgets();
    $self->addModelListeners();
    
    return $self;
}


sub makeMenu {
    my ($self) = @_;
    my $gui = $self->{parent};
    my $menu = $gui->new_menu();
    
    my $options = $menu->new_menu(-tearoff => 0);    
    
    $menu->add_cascade(
        -label     => "Options",
        -underline => 0,
        -menu      => $options,
    );
    
    $options->add_command(
        -label       => "Save report",
        -accelerator => "Ctrl+S", # is this just a message, or does it do something?
        -command     => sub {$self->saveReport();},
    );
    $gui->g_bind("<Control-s>", sub {$self->saveReport();});
    
    $options->add_command(
        -label       => "Select row color",
        -command     => sub {$self->chooseColor();},
    );
    
    $options->add_command(
        -label       => "Close window",
        -accelerator => "Ctrl+W",
        -command     => sub {$self->cleanUp();},
    );
    $gui->g_bind("<Control-w>", sub {$self->cleanUp();});
    
    $gui->configure(-menu => $menu);
}


sub cleanUp {
    my ($self) = @_;
    my $gui = $self->{parent};
    my @ids = @{$self->{listenerIds}};
    INFO("cleaning up reports window -- removing " . scalar(@ids) . " listeners");
    for my $id (@ids) {
        &Messages::removeListener(@$id); # deref as array b/c model needs 2 args
    }
    $gui->Tkx::destroy();
}


sub layoutWidgets {
    my ($self) = @_;
    my ($frame) = $self->{frame};

    $frame->g_grid_columnconfigure(1, -weight => 1);
    $frame->g_grid_rowconfigure(2, -weight => 1);

    $self->{cbox}->g_grid(-row => 0, -column => 0);
    $self->{displayReport}->g_grid(-row => 1, -column => 0, -sticky => 'ew');
    $self->{viewer}->g_grid(-row => 0, -column => 1, -rowspan => 30, -sticky => 'nsew');
}


sub fetchAndDisplayReport {
    my ($self) = @_;
    my $reportName = $self->{cbox}->getSelected();
    INFO("selected report: $reportName");    
    
    my ($report) = &Service::getReport($reportName);
    $self->{viewer}->displayResults($report->getHeadings(), $report->getRows());
    $self->{report} = $report;
    $self->resetColors();
}


sub resetColors {
    my ($self) = @_;
    $self->{cbox}->setDefaultColor();
}


sub saveReport {
    my ($self) = @_;
    die "no report to save" unless $self->{report};
    my $filename = Tkx::tk___getSaveFile();
    return unless $filename;
    
    INFO("writing report to file <$filename>");
    
    open(my $file, ">$filename") || die "can't open file $filename for writing";
    
    my @headings = @{$self->{report}->getHeadings()};
    my @rows = @{$self->{report}->getRows()};
    
    my $headline = join("\t", @headings);
    print $file "$headline\n";
    for my $row (@rows) {
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

######################################################
#### subscribe to model events

sub onModelChange {
    my ($self, $status) = @_;
    if($status eq "success") {
        $self->fetchAndDisplayReport();
    } elsif($status eq "failure") {
        # nothing to do
    } else {
        die "invalid status: <$status>";
    }
}


sub addModelListeners {
    my ($self) = @_;
    my $trans = sub {
        INFO("change in model reported ... updating report");
        $self->onModelChange(@_);
    };
    my @pairs = ();
    my @events = ("saveTrans", "editTrans", "deleteTrans", "saveBalance");
    for my $event (@events) {
        # return value is a pair of (event type, listener id)
        my @pair = &Messages::addListener($event, $trans);
        die "haven't implemented capturing listener ids yet (for later removal)";
        push(@pairs, \@pair);
    }
    $self->{listenerIds} = \@pairs;
}


1;
