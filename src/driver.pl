use strict;
use warnings;

BEGIN {push(@INC, 'gui')}; # is there a better way to get this file to see the other files?

use Tkx;
use Model;
use FinanceGUI;
use Log::Log4perl qw(:easy);
use Database;
use Try::Tiny;


BEGIN {
    Log::Log4perl->easy_init({
        level   => $DEBUG,
        file    => ">>financeLog.txt",
        layout  => '%p  %F{1}-%L-%M: (%d) %m%n' 
    });
}


INFO("initializing database connection");

my $dbh;
try {
    $dbh = Database::getDBConnection();
} catch {
    FATAL("failed to connect to database: $_");
    Tkx::tk___messageBox(-message => "fatal error: $_");
    die $_;
};


INFO("initializing model");

my $model;
try {
    $model = Model->new($dbh);
} catch {
    FATAL("failed to initialize model: $_");
    Tkx::tk___messageBox(-message => "fatal error: $_");
    die $_;
};


INFO("initializing GUI");

my $gui;
try {
    $gui = FinanceGUI->new($model);
} catch {
    FATAL("failed to initialize gui: $_");
    Tkx::tk___messageBox(-message => "fatal error: $_");    
    die $_;
};


INFO("starting Tkx::MainLoop");

&Tkx::MainLoop();

INFO("exiting FinanceManager -- cleaning up");

$model->cleanUp();
