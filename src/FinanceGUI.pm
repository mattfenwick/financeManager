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
#use ConfirmTransactions;



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
#    $self->makeMenu();
    my $n = $gui->new_ttk__notebook;
    $self->makeNotebook($n);
    $gui->g_grid_columnconfigure(0, -weight => 1);
    $gui->g_grid_rowconfigure(0, -weight => 1);
    $n->g_grid(-sticky => 'nsew');
#    $gui->g_grid_columnconfigure(0, -weight => 1);
    return $self;
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
    my $report = $n->new_ttk__frame;
    $self->makeViewFrame($report);
    my $f4 = $n->new_ttk__frame;
    $n->add($add, -text => "Add transactions");
    $n->add($edit, -text => "Edit transactions");
    $n->add($balance, -text => "Monthly balances");
#    $n->add($confirm, -text => "Confirm transactions");
    $n->add($report, -text => "View reports");
    $n->add($f4, -text => "SQL interpreter");
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


sub makeViewFrame {
    my ($self, $parent) = @_;
    $parent->g_grid_columnconfigure(0, -weight => 1);
    $parent->g_grid_rowconfigure(0, -weight => 1);
    my $vf = Reports->new($parent, $self->{controller});
    $vf->g_grid(-sticky => 'nsew');
}

#sub makeConfirmFrame {
#    my ($self, $parent) = @_;
#    my $confirmFrame = ConfirmTransactions->new($parent, $self->{controller});
#    $confirmFrame->g_grid();
#}


1;