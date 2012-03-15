use strict;
use warnings;

use Log::Log4perl qw(:easy);
use Tkx;
use Try::Tiny;

use Model;
use Database;

use lib 'gui';
use FinanceGUI;


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
