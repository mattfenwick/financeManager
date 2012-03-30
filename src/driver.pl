use strict;
use warnings;

use Log::Log4perl qw(:easy);
use Tkx;
use Try::Tiny;

use lib 'model';
use Transaction;
use Balance;
use MiscData;
use Report;

use lib 'database';
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
    $dbh = &Database::getDBConnection();
} catch {
    FATAL("failed to connect to database: $_");
    Tkx::tk___messageBox(-message => "fatal error: $_");
    die $_;
};


INFO("initializing service layer and model");

my $service;
try {
    $service = Service->new($dbh);
} catch {
    FATAL("failed to initialize service layer and model: $_");
    Tkx::tk___messageBox(-message => "fatal error: $_");
    die $_;
};


INFO("initializing GUI");

my $gui;
try {
    $gui = FinanceGUI->new($service);
} catch {
    FATAL("failed to initialize gui: $_");
    Tkx::tk___messageBox(-message => "fatal error: $_");    
    die $_;
};


INFO("starting Tkx::MainLoop");

&Tkx::MainLoop();

INFO("disconnecting from database server");

$dbh->disconnect();

INFO("exiting FinanceManager");
