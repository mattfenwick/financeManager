use strict;
use warnings;
use Tkx;
use Controller;
use FinanceGUI;
use Log::Log4perl qw(:easy);

BEGIN {
    Log::Log4perl->easy_init( 
        { level   => $DEBUG,
            file    => ">>financeLog.txt",
            layout   => '%p  %F{1}-%L-%M: (%d) %m%n' 
        } 
    );
}


INFO("starting FinanceManager");

my $controller = Controller->new();

INFO("initializing finance GUI");

my $gui = FinanceGUI->new($controller);

INFO("starting Tkx::MainLoop");

&Tkx::MainLoop();

INFO("exiting FinanceManager -- cleaning up");

$controller->cleanUp();