use strict;
use warnings;

package TestDatabase;

use Test::More;
use Log::Log4perl qw(:easy);
use Try::Tiny;

use lib '../src/database';
use Database;


sub runTests {
    
    subtest 'connect to database' => sub {
        try {
            my $dbh = &Database::getDBConnection();
            ok(1, "connected to database");
        } catch {
            ok(0, "couldn't connect to database");
        };
    };
    
    subtest 'disconnect from database' => sub {
        try {
            my $dbh = &Database::getDBConnection();
            $dbh->disconnect();
            ok(1, "connected to and disconnected from database");
        } catch {
            ok(0, "couldn't connect/disconnect to database");
        };
    };
    
}

1;