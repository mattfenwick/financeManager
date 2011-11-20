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
          layout  => '%p  %F{1}-%L-%M: (%d) %m%n' 
        } 
    );
}

INFO("starting FinanceManager");

my $controller;
eval{
	$controller = Controller->new();
} || do {
	FATAL("failed to initialize controller: $@");
    Tkx::tk___messageBox(-message => "fatal error: $@");
    die $@;
};

INFO("initializing finance GUI");

my $gui;
eval {
	$gui = FinanceGUI->new($controller);
} || do {
	FATAL("failed to initialize gui: $@");
    Tkx::tk___messageBox(-message => "fatal error: $@");	
	die $@;
};

INFO("starting Tkx::MainLoop");

&Tkx::MainLoop();

INFO("exiting FinanceManager -- cleaning up");

$controller->cleanUp();

