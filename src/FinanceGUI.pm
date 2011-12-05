use strict;
use warnings;


package FinanceGUI;
use LabelEntry;    
use Data::Dumper;
use ComboBox;
use Reports;
use AddTransaction;
use EditTransaction;
use Balances;


my $address = "https://github.com/mattfenwick/financeManager";
my $version = "1.0.3a";


sub new {
    my ($class, $controller) = @_;
    my $self = {
        gui => Tkx::widget->new("."),
        controller => $controller,
    };
    bless($self, $class);
    my $gui = $self->{gui};
    $gui->g_wm_minsize(200, 2);
    $gui->g_wm_title("Account manager");
    $self->makeMenu();
    my $n = $gui->new_ttk__notebook;
    $self->makeNotebook($n);
    $gui->g_grid_columnconfigure(0, -weight => 1);
    $gui->g_grid_rowconfigure(0, -weight => 1);
    $n->g_grid(-sticky => 'nsew');
#    $gui->g_grid_columnconfigure(0, -weight => 1);
    return $self;
}


sub makeMenu {
    my ($self) = @_;
    my $gui = $self->{gui};
    my $menu = $gui->new_menu();

    my $file = $menu->new_menu(-tearoff => 0);
    my $help = $menu->new_menu(-tearoff => 0);
    
    $menu->add_cascade(
        -label     => "File",
        -underline => 0,
        -menu      => $file,
    );
    
    $file->add_command(
        -label       => "View reports",
        -accelerator => "Ctrl+R", # is this just a message, or does it do something?
        -command     => [\&viewReports, $self],
    );
    $gui->g_bind("<Control-r>", [\&viewReports, $self]);
    
    $file->add_command(
        -label     => "Exit",
        -underline => 1,
        -command   => sub {$gui->Tkx::destroy();},
    );
    
    $menu->add_cascade(
        -label     => "Help",
        -underline => 0,
        -menu      => $help,
    );
    
    $help->add_command(
        -label      => "About",
        -command    => \&displayVersion,
    );
    
    $help->add_command(
        -label      => "Visit website",
        -command    => \&displayWebsite,
    );
  
    $gui->configure(-menu => $menu);
}


sub displayVersion {
    my $message = "This is version $version of FinanceManager, developed by Matt Fenwick";
    Tkx::tk___messageBox(-message => $message);
}


sub displayWebsite {
    Tkx::tk___messageBox(-message => "Please go to:  " . $address);
}


sub makeNotebook {
    my ($self, $n) = @_;
    my $add = $n->new_ttk__frame; 
    $self->makeAddFrame($add);
    my $edit = $n->new_ttk__frame;
    $self->makeEditFrame($edit);
    my $balance = $n->new_ttk__frame();
    $self->makeBalanceFrame($balance);
#    my $confirm = $n->new_ttk__frame;
#    $self->makeConfirmFrame($confirm);
    $n->add($add, -text => "Add transactions");
    $n->add($edit, -text => "Edit transactions");
    $n->add($balance, -text => "Monthly balances");
#    $n->add($confirm, -text => "Confirm transactions");
    return $n;
}


sub makeAddFrame {
    my ($self, $parent) = @_;
    my $addFrame = AddTransaction->new($parent, $self->{controller});
    $addFrame->g_grid();
}


sub makeEditFrame {
    my ($self, $parent) = @_;
    my $editFrame = EditTransaction->new($parent, $self->{controller});
    $editFrame->g_grid();
}


sub makeBalanceFrame {
    my ($self, $parent) = @_;
    my $balFrame = Balances->new($parent, $self->{controller});
    $balFrame->g_grid();
}


sub viewReports {
    my ($self) = @_;
    my $gui = $self->{gui};
    my $top = $gui->new_toplevel();
    $top->g_wm_minsize(500, 2);
    $top->g_wm_title("View Reports");
    $top->g_grid_columnconfigure(0, -weight => 1);
    $top->g_grid_rowconfigure(0, -weight => 1);
    my $reportWindow = Reports->new($top, $self->{controller});
    $reportWindow->g_grid(-sticky => 'nsew');
}


1;