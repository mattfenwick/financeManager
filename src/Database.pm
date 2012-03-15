use strict;
use warnings;

package Database;
use DBI;
use Log::Log4perl qw(:easy);


my $database    = "finance";
my $user        = "financeclient";
my $password    = "financeclient";



sub getDBConnection {
    INFO("attempting to connect to database");
    my $dbh = DBI->connect("DBI:mysql:" . $database, 
        $user, $password, {RaiseError => 1});
    INFO("database connection succeeded -- $database $user");
    return $dbh;
}


1;